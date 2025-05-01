local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local lsp = vim.lsp
local log = vim.log
local uv = vim.uv

local M = {}

local last_progress = nil
local progress_redraw_pending = false
local progress_redraw_debounce_timer = assert(uv.new_timer())

local function update_progress(opts)
  local client = lsp.get_client_by_id(opts.data.client_id)
  if not client then
    return
  end

  last_progress = nil
  local msg = opts.data.params.value
  if msg.kind ~= "end" then
    local text = msg.title
    if msg.message then
      text = text .. " " .. msg.message
    end
    if msg.percentage then
      text = text .. " " .. math.floor(msg.percentage) .. "%"
    end

    last_progress = { client_id = client.id, text = text }
  end

  progress_redraw_pending = true

  local function redraw()
    local cmdheight = vim.o.cmdheight
    if
      progress_redraw_pending
      and api.nvim_get_mode().mode == "n"
      and cmdheight > 0
    then
      local str = ""
      if last_progress then
        str = ("LSP[%s] %s")
          :format(
            lsp.get_client_by_id(last_progress.client_id).name,
            last_progress.text
          )
          :gsub("%s", " ") -- Particularly deal with possible NLs and tabs.

        local max_screen_len = vim.o.columns * (cmdheight - 1) + vim.v.echospace
        if fn.strdisplaywidth(str) > max_screen_len then
          -- Not accurate as sub uses byte indices, but low-effort.
          str = str:sub(1, max_screen_len - 1) .. "…"
        end
      end

      vim.cmd.redraw() -- Avoid hit-ENTER from any prior echoes.
      api.nvim_echo({ { str } }, false, {})
    end

    progress_redraw_pending = false
  end

  -- Don't spam redraws.
  if progress_redraw_debounce_timer:get_due_in() == 0 then
    redraw()
    progress_redraw_debounce_timer:start(250, 0, vim.schedule_wrap(redraw))
  end
end

api.nvim_create_autocmd("LspProgress", {
  group = api.nvim_create_augroup("conf_lsp_progress", {}),
  callback = update_progress,
})

local function statusline(_, stlwin)
  local function escape(text)
    return text:gsub("%%", "%%%%")
  end

  local chunks = {}
  local buf = api.nvim_win_get_buf(stlwin)
  local clients = lsp.get_clients { bufnr = buf }
  if #clients == 1 then
    chunks[#chunks + 1] = escape(clients[1].name)
  elseif #clients > 1 then
    chunks[#chunks + 1] = #clients .. " clients"
  end

  if lsp.inlay_hint.is_enabled { bufnr = buf } then
    chunks[#chunks + 1] = "IH"
  end
  if fn.has "nvim-0.12" == 1 and lsp.document_color.is_enabled(buf) then
    chunks[#chunks + 1] = "DC"
  end
  return #chunks > 0 and "[LSP(" .. table.concat(chunks, ",") .. ")] " or ""
end

if fn.has "nvim-0.12" == 1 then
  api.nvim_create_autocmd({ "OptionSet", "UILeave" }, {
    callback = function(args)
      if args.event == "OptionSet" and args.match ~= "termguicolors" then
        return
      end
      if vim.o.termguicolors or fn.has "gui_running" == 1 then
        return
      end
      -- Document colours are useless without "true" colour support.
      for _, buf in ipairs(api.nvim_list_bufs()) do
        if lsp.document_color.is_enabled(buf) then
          lsp.document_color.enable(false, buf)
        end
      end
    end,
  })
end

fn["conf#statusline#define_component"]("lsp", statusline)

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
  for _, buf in ipairs(lsp.get_buffers_by_client_id(client_id)) do
    local buf_clients = vim.tbl_filter(function(c)
      return not detaching or c.id ~= client_id
    end, lsp.get_clients { bufnr = buf })

    local function buf_supports_method(method)
      return vim.iter(buf_clients):any(function(c)
        return c:supports_method(method)
      end)
    end
    local function buf_reset_option(option)
      vim.bo[buf][option] =
        api.nvim_get_option_value(option, { filetype = vim.bo[buf].filetype })
    end

    if buf_supports_method "textDocument/hover" then
      keymap.set("n", "K", lsp.buf.hover, { buffer = buf, desc = "LSP Hover" })
    else
      pcall(keymap.del, "n", "K", { buffer = buf })
    end

    if buf_supports_method "textDocument/definition" then
      vim.bo[buf].tagfunc = "v:lua.vim.lsp.tagfunc"
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
      vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    else
      buf_reset_option "omnifunc"
    end

    if buf_supports_method "textDocument/rangeFormatting" then
      -- Prefer ours.
      vim.bo[buf].formatexpr = "v:lua.require'conf.lsp'.formatexpr()"
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
  M.setup_attached_buffers(args.data.client_id, true)
  lsp.completion.enable(false, args.data.client_id, args.bufnr)

  if last_progress and last_progress.client_id == args.data.client_id then
    last_progress = nil
    api.nvim_echo({}, false, {}) -- Clear old progress message.
  end

  -- Schedule, as the client hasn't finished detaching yet.
  vim.schedule(function()
    vim.cmd.redrawstatus { bang = true }
  end)
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
