local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local lsp = vim.lsp
local log = vim.log

local M = {}

--- @class ProgressMsg (exact)
--- @field id integer|string
--- @field running boolean

local client_id_to_progress = {} --- @type table<integer, ProgressMsg>

api.nvim_create_autocmd("LspProgress", {
  group = api.nvim_create_augroup("conf_lsp_progress", {}),
  callback = function(args)
    local client_id = args.data.client_id
    local client = lsp.get_client_by_id(client_id)
    if not client then
      return
    end

    local params = args.data.params.value
    local chunks = {}
    if params.title then
      chunks[#chunks + 1] = params.title
    end
    if params.message then
      chunks[#chunks + 1] = params.message
    end
    if params.kind == "end" then
      chunks[#chunks + 1] = "(done)"
    end

    local progress = client_id_to_progress[client_id]
    local id = api.nvim_echo({ { table.concat(chunks, " ") } }, false, {
      id = progress and progress.id or nil,
      kind = "progress",
      title = ("LSP[%s]"):format(client.name),
      percent = params.percentage,
      status = params.kind ~= "end" and "running" or "success",
    })
    assert(id ~= -1 and (not progress or id == progress.id))
    if not progress then
      progress = { id = id, running = false }
      client_id_to_progress[client_id] = progress
    end
    progress.running = params.kind ~= "end"
  end,
})

require("conf.statusline").components.lsp = function(_, stl_win)
  local function escape(text)
    return text:gsub("%%", "%%%%")
  end

  local chunks = {}
  local buf = api.nvim_win_get_buf(stl_win)
  local clients = lsp.get_clients { bufnr = buf }
  if #clients == 1 then
    chunks[#chunks + 1] = escape(clients[1].name)
  elseif #clients > 1 then
    chunks[#chunks + 1] = #clients .. " clients"
  end

  if lsp.inlay_hint.is_enabled { bufnr = buf } then
    chunks[#chunks + 1] = "IH"
  end
  return #chunks > 0 and "[LSP(" .. table.concat(chunks, ",") .. ")] " or ""
end

-- Similar to vim.lsp.formatexpr(), but uses vim.lsp.buf.format{async = true},
-- falling back to built-in formatting when automatically invoked.
function M.formatexpr()
  if vim.v.char ~= "" then
    return 1 -- Use built-in formatting when automatically invoked.
  end
  lsp.buf.format {
    async = true,
    range = {
      start = { vim.v.lnum, 0 },
      ["end"] = { vim.v.lnum + vim.v.count - 1, 0 },
    },
  }
  return 0
end

function M.setup_attached_buffers(client_id, detaching)
  local has_stylua = fn.executable "stylua" == 1

  for _, buf in ipairs(lsp.get_buffers_by_client_id(client_id)) do
    local buf_clients = vim.tbl_filter(function(c)
      return not detaching or c.id ~= client_id
    end, lsp.get_clients { bufnr = buf })

    --- @param method string
    --- @param filter (fun(vim.lsp.Client): boolean)?
    --- @return boolean
    --- @nodiscard
    local function buf_supports_method(method, filter)
      filter = filter or function(_)
        return true
      end
      return vim.iter(buf_clients):filter(filter):any(function(c)
        return c:supports_method(method)
      end)
    end

    --- @param option string
    local buf_reset_option = vim.schedule_wrap(function(option)
      -- Scheduled, as we can't use nvim_get_option_value with "filetype" set
      -- in FileType autocmds, which LspAttach/Detach may be triggered from.
      -- HACK: This is a bit fragile; will be properly fixed by
      -- neovim/neovim#33919.
      if api.nvim_buf_is_valid(buf) then
        vim.bo[buf][option] =
          api.nvim_get_option_value(option, { filetype = vim.bo[buf].filetype })
      end
    end)

    --- @param option string
    --- @param value any
    local buf_set_option = vim.schedule_wrap(function(option, value)
      -- HACK: Scheduled for the same reason as above, as we want this to happen
      -- after possibly resetting the option.
      if api.nvim_buf_is_valid(buf) then
        vim.bo[buf][option] = value
      end
    end)

    if buf_supports_method "textDocument/hover" then
      keymap.set("n", "K", lsp.buf.hover, { buffer = buf, desc = "LSP Hover" })
    else
      pcall(keymap.del, "n", "K", { buffer = buf })
    end

    if buf_supports_method "textDocument/definition" then
      buf_set_option("tagfunc", "v:lua.vim.lsp.tagfunc")
      keymap.set(
        "n",
        "gd",
        lsp.buf.definition,
        { buffer = buf, desc = "LSP Definition" }
      )
    else
      buf_reset_option "tagfunc"
      pcall(keymap.del, "n", "gd", { buffer = buf })
    end

    if buf_supports_method "textDocument/declaration" then
      keymap.set(
        "n",
        "gD",
        lsp.buf.declaration,
        { buffer = buf, desc = "LSP Declaration" }
      )
    else
      pcall(keymap.del, "n", "gD", { buffer = buf })
    end

    if buf_supports_method "textDocument/completion" then
      buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
    else
      buf_reset_option "omnifunc"
    end

    if
      buf_supports_method("textDocument/rangeFormatting", function(client)
        -- Prefer stylua formatter set by my Lua ftplugin over lua_ls' use of
        -- EmmyLuaCodeStyle.
        return not has_stylua or client.name ~= "lua_ls"
      end)
    then
      -- Prefer ours.
      buf_set_option("formatexpr", "v:lua.require'conf.lsp'.formatexpr()")
    else
      buf_reset_option "formatexpr"
    end

    local folding = require "conf.folding"
    folding.enable(
      buf,
      folding.type.LSP,
      buf_supports_method "textDocument/foldingRange"
    )
  end
end

function M.attach_buffer(args)
  M.setup_attached_buffers(args.data.client_id)
  lsp.completion.enable(true, args.data.client_id, args.bufnr)

  -- Schedule, as the window may not have been drawn yet, which could cause
  -- a full screen redraw from `:redrawstatus!`; this can introduce a "flicker"
  -- if another redraw happens later (e.g: setting cursor position).
  vim.schedule(function()
    vim.cmd.redrawstatus { bang = true }
  end)
end

function M.detach_buffer(args)
  local client_id = args.data.client_id
  M.setup_attached_buffers(client_id, true)
  lsp.completion.enable(false, client_id, args.bufnr)

  -- Schedule, as the client hasn't finished detaching yet.
  vim.schedule(function()
    vim.cmd.redrawstatus { bang = true }
  end)
end

function M.client_on_exit(_, _, client_id)
  local progress = client_id_to_progress[client_id]
  if progress and progress.running then
    local client = assert(lsp.get_client_by_id(client_id))
    vim.schedule(function()
      local id = api.nvim_echo({ { "client exited during work" } }, false, {
        id = progress.id,
        kind = "progress",
        title = ("LSP[%s]"):format(client.name),
        status = "cancel",
      })
      assert(id == progress.id)
    end)
  end
  client_id_to_progress[client_id] = nil
end

--- @param args vim.api.keyset.create_user_command.command_args
--- @param enabled_configs table<string>
function M.start_command(args, enabled_configs)
  local configs = {}
  if #args.fargs == 0 then
    -- Find configs to use for the filetype(s) from our usual enable list.
    local buf_filetypes = vim.split(vim.bo.filetype, ".", { plain = true })
    configs = vim
      .iter(enabled_configs)
      :map(function(name)
        return vim.lsp.config[name]
      end)
      :filter(function(config)
        return not config.filetypes
          or vim.tbl_contains(
            config.filetypes,
            --- @param ft string
            function(ft)
              return vim.tbl_contains(buf_filetypes, ft)
            end,
            { predicate = true }
          )
      end)
      :totable()

    if #configs == 0 then
      vim.notify("No matching LSP configurations for buffer", log.levels.WARN)
      return
    end
  else
    -- Get the configs from the supplied names.
    for _, name in ipairs(args.fargs) do
      local config = vim.lsp.config[name]
      if not config then
        vim.notify(
          ('No such LSP configuration: "%s"'):format(name),
          log.levels.ERROR
        )
        return
      end
      configs[#configs + 1] = config
    end
  end

  for _, config in ipairs(configs) do
    config = vim.deepcopy(config)
    local buf = api.nvim_get_current_buf()
    local function start_config()
      lsp.start(config, {
        bufnr = buf,
        reuse_client = config.reuse_client,
        _root_markers = config.root_markers,
      })
    end

    if type(config.root_dir) == "function" then
      --- @param root_dir string
      config.root_dir(buf, function(root_dir)
        config.root_dir = root_dir
        vim.schedule(start_config)
      end)
    else
      start_config()
    end
  end
end

--- @param args vim.api.keyset.create_user_command.command_args
function M.stop_command(args)
  --- @param clients table<vim.lsp.Client>
  local function stop_clients(clients)
    for _, client in ipairs(clients) do
      client:stop(args.bang)
    end
  end

  if #args.fargs == 0 then
    stop_clients(lsp.get_clients { bufnr = 0 })
  else
    for _, name in ipairs(args.fargs) do
      stop_clients(lsp.get_clients { bufnr = 0, name = name })
    end
  end
end

return M
