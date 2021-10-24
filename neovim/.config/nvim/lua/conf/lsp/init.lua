if vim.fn.has "nvim-0.6" == 0 then
  return nil
end

local api = vim.api
local cmd = vim.cmd
local lsp = vim.lsp
local uv = vim.loop

cmd "packadd nvim-lspconfig"
local lspconfig = require "lspconfig"

local servers = require "conf.lsp.servers"
local bmap = require("conf.util").bmap

local M = {
  progress = "",
  diagnostics_float_timer = uv.new_timer(),
}

local function is_attached(buf)
  return vim.tbl_count(lsp.buf_get_clients(buf)) ~= 0
end

function M.statusline(is_current)
  if is_current and M.progress ~= "" then
    return "[" .. M.progress .. "] "
  end
  return is_attached() and "[LSP] " or ""
end

function M.update_progress()
  local new_msgs = lsp.util.get_progress_messages()
  local msg = new_msgs[#new_msgs]

  local progress = ""
  if msg and not msg.done then
    progress = msg.name .. ": "

    if msg.progress then
      progress = progress .. msg.title
      if msg.message then
        progress = progress .. " " .. msg.message
      end
      if msg.percentage then
        progress = progress .. " " .. math.floor(msg.percentage) .. "%%"
      end
    else
      -- TODO: maybe show URI if msg.status == true?
      progress = progress .. msg.content
    end
  end

  M.progress = progress
  cmd "redrawstatus"

  if M.progress_clear_timer then
    M.progress_clear_timer:stop()
  end
  if not msg.done then
    M.progress_clear_timer = vim.defer_fn(function()
      M.progress = ""
      cmd "redrawstatus"
    end, 2750)
  end
end

function M.opened_float(buf)
  buf = buf or api.nvim_get_current_buf()
  local ok, win = pcall(api.nvim_buf_get_var, buf, "lsp_floating_preview")
  if not ok or not api.nvim_win_is_valid(win) then
    return nil
  end
  return win
end

function M.close_float(buf)
  buf = buf or api.nvim_get_current_buf()
  local win = M.opened_float(buf)
  if win then
    api.nvim_win_close(win, true)
  end
end

function M.restart_diagnostics_timer(ms)
  ms = ms or 1500
  M.diagnostics_float_timer:stop()
  if not is_attached() then
    return
  end
  M.diagnostics_float_timer:start(
    ms,
    0,
    vim.schedule_wrap(function()
      if not M.opened_float() and api.nvim_get_mode().mode == "n" then
        vim.lsp.diagnostic.show_line_diagnostics {
          focusable = false,
          border = "single",
        }
      end
    end)
  )
end

local function on_attach(client, _)
  vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"

  bmap("n", "<esc>", "<cmd>lua require('conf.lsp').close_float()<cr><esc>")

  if client.name == "clangd" then
    bmap("n", "<space>s", "<cmd>ClangdSwitchSourceHeader<cr>")
  end

  bmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
  bmap("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")
  bmap("i", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")

  bmap("n", "<space><space>", "<cmd>Telescope lsp_workspace_diagnostics<cr>")

  bmap("n", "<c-]>", "<cmd>lua vim.lsp.buf.definition()<cr>")
  bmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
  bmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
  bmap("n", "<space>t", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
  bmap("n", "<space>i", "<cmd>Telescope lsp_implementations<cr>")
  bmap("n", "<space>r", "<cmd>Telescope lsp_references<cr>")

  bmap("n", "<space>R", "<cmd>lua vim.lsp.buf.rename()<cr>")
  bmap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<cr>")
  bmap("x", "<space>f", "<esc><cmd>lua vim.lsp.buf.range_formatting()<cr>")
  bmap("n", "<space>a", "<cmd>Telescope lsp_code_actions<cr>")
  bmap("x", "<space>a", "<esc><cmd>Telescope lsp_range_code_actions<cr>")

  bmap("n", "<space>w", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>")
  bmap("n", "<space>d", "<cmd>Telescope lsp_document_symbols<cr>")
end

local default_config = {
  on_attach = on_attach,
  handlers = {
    ["textDocument/hover"] = lsp.with(lsp.handlers.hover, {
      border = "single",
    }),
    ["textDocument/signatureHelp"] = lsp.with(
      lsp.handlers.signature_help,
      { border = "single" }
    ),
    ["textDocument/formatting"] = function(...)
      lsp.handlers["textDocument/formatting"](...)
      cmd "echo 'Buffer formatted!'"
    end,
    ["textDocument/rangeFormatting"] = function(...)
      lsp.handlers["textDocument/rangeFormatting"](...)
      cmd "echo 'Range formatted!'"
    end,
  },
}

for _, config in ipairs(servers) do
  local name
  if type(config) == "string" then
    name = config
    config = {}
  else
    name = config.name
    config.name = nil
  end

  lspconfig[name].setup(vim.tbl_deep_extend("force", default_config, config))
end

cmd [[
  augroup conf_lsp_update_progress
    autocmd!
    autocmd User LspProgressUpdate lua require("conf.lsp").update_progress()
  augroup END

  augroup conf_lsp_cursor_diagnostics
    autocmd!
    autocmd CursorMoved * lua require("conf.lsp").restart_diagnostics_timer()
    autocmd User LspDiagnosticsChanged
        \ lua require("conf.lsp").restart_diagnostics_timer()
  augroup END
]]

return M
