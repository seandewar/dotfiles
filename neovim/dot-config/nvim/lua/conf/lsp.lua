local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local lsp = vim.lsp
local log = vim.log

local M = {}

local progress_echo_id
local scheduled_progress, last_echoed_progress

local function echo_progress(progress, cancel)
  local msg = progress.msg
  local chunks = {}
  if msg.title then
    chunks[#chunks + 1] = msg.title
  end
  if msg.message then
    chunks[#chunks + 1] = msg.message
  end
  if cancel then
    chunks[#chunks] = chunks[#chunks] .. "...cancelled"
  elseif msg.kind == "end" then
    chunks[#chunks] = chunks[#chunks] .. "...done"
  end

  local id = api.nvim_echo({ { table.concat(chunks, " ") } }, false, {
    id = progress_echo_id,
    kind = "progress",
    title = ("LSP[%s]"):format(progress.client_name),
    percent = not cancel and msg.percentage or nil,
    status = cancel and "cancel"
      or msg.kind == "begin" and "running"
      or "success",
  })
  progress_echo_id = id ~= -1 and id or progress_echo_id
end

api.nvim_create_autocmd("LspProgress", {
  group = api.nvim_create_augroup("conf_lsp_progress", {}),
  callback = function(args)
    local client_id = args.data.client_id
    local client = lsp.get_client_by_id(client_id)
    if not client then
      return
    end
    local need_schedule = not scheduled_progress
    scheduled_progress = {
      msg = args.data.params.value,
      client_name = client.name,
      client_id = client_id,
    }

    if need_schedule then
      vim.schedule(function()
        echo_progress(scheduled_progress)
        last_echoed_progress = scheduled_progress.msg.kind ~= "begin"
            and scheduled_progress
          or nil
        scheduled_progress = nil
      end)
    end
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

  for buf, _ in pairs(lsp.get_client_by_id(client_id).attached_buffers) do
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
          vim.filetype.get_option(vim.bo[buf].filetype, option)
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

--- @param args vim.api.keyset.create_autocmd.callback_args
function M.attach_buffer(args)
  M.setup_attached_buffers(args.data.client_id)
  lsp.completion.enable(true, args.data.client_id, args.buf)

  -- Schedule, as the window may not have been drawn yet, which could cause
  -- a full screen redraw from `:redrawstatus!`; this can introduce a "flicker"
  -- if another redraw happens later (e.g: setting cursor position).
  vim.schedule(function()
    vim.cmd.redrawstatus { bang = true }
  end)
end

--- @param args vim.api.keyset.create_autocmd.callback_args
function M.detach_buffer(args)
  M.setup_attached_buffers(args.data.client_id, true)
  lsp.completion.enable(false, args.data.client_id, args.buf)

  -- Schedule, as the client hasn't finished detaching yet.
  vim.schedule(function()
    vim.cmd.redrawstatus { bang = true }
  end)
end

function M.client_on_exit(_, _, client_id)
  if last_echoed_progress and last_echoed_progress.client_id == client_id then
    local progress = last_echoed_progress
    vim.schedule(function()
      echo_progress(progress, true)
    end)

    if scheduled_progress and scheduled_progress.client_id == client_id then
      scheduled_progress = nil
    end
    last_echoed_progress = nil
  end
end

return M
