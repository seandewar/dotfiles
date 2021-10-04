local api = vim.api
local uv = vim.loop
local lsp = vim.lsp

local config_mod = require "lsp_conf.config"
local lspconfig = require "lspconfig"

-- Global, as this file isn't usually require()'d (allows reloading)
lsp_conf = {
  progress = "",
  diagnostics_float_timer = uv.new_timer(),
}

local function is_attached(buf)
  buf = buf or api.nvim_get_current_buf()
  return not vim.tbl_isempty(lsp.buf_get_clients(buf))
end

function lsp_conf.statusline(is_current)
  if is_current and lsp_conf.progress ~= "" then
    return "[" .. lsp_conf.progress .. "] "
  end
  return vim.tbl_count(lsp.buf_get_clients()) ~= 0 and "[LSP] " or ""
end

function lsp_conf.update_progress()
  local new_msgs = lsp.util.get_progress_messages()
  local msg = new_msgs[#new_msgs]

  local progress = ""
  if msg then
    progress = msg.name .. ": "
    if msg.progress then
      progress = progress .. msg.title .. " "
      if msg.message then
        progress = progress .. msg.message .. " "
      end
      if msg.percentage then
        progress = progress .. math.floor(msg.percentage) .. "%%"
      end
    else
      -- TODO: maybe show URI if msg.status == true?
      progress = progress .. msg.content
    end
  end

  lsp_conf.progress = progress
  vim.cmd "redrawstatus"

  if lsp_conf.progress_clear_timer then
    lsp_conf.progress_clear_timer:stop()
  end
  lsp_conf.progress_clear_timer = vim.defer_fn(function()
    lsp_conf.progress = ""
    vim.cmd "redrawstatus"
  end, 2750)
end

function lsp_conf.opened_float(buf)
  buf = buf or api.nvim_get_current_buf()
  local ok, win = pcall(api.nvim_buf_get_var, buf, "lsp_floating_preview")
  if not ok or not api.nvim_win_is_valid(win) then
    return nil
  end
  return win
end

function lsp_conf.close_float(buf)
  buf = buf or api.nvim_get_current_buf()
  local win = lsp_conf.opened_float(buf)
  if win then
    api.nvim_win_close(win, true)
  end
end

function lsp_conf.restart_diagnostics_timer(ms)
  ms = ms or 1500
  lsp_conf.diagnostics_float_timer:stop()
  if vim.tbl_isempty(lsp.buf_get_clients(0)) then
    return
  end
  lsp_conf.diagnostics_float_timer:start(
    ms,
    0,
    vim.schedule_wrap(function()
      if not lsp_conf.opened_float() and api.nvim_get_mode().mode == "n" then
        vim.lsp.diagnostic.show_line_diagnostics {
          focusable = false,
          border = "single",
        }
      end
    end)
  )
end

local function map(mode, lhs, rhs)
  api.nvim_buf_set_keymap(0, mode, lhs, rhs, { noremap = true, silent = true })
end

local function on_attach(client, _)
  vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"

  map("n", "<esc>", "<cmd>lua lsp_conf.close_float()<cr><esc>")

  if client.name == "clangd" then
    map("n", "<space>s", "<cmd>ClangdSwitchSourceHeader<cr>")
  end

  map("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
  map("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")
  map("i", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")

  map(
    "n",
    "]<space>",
    "<cmd>lua vim.lsp.diagnostic.goto_next("
      .. "{popup_opts = {border = 'single'}})<cr>"
  )
  map(
    "n",
    "[<space>",
    "<cmd>lua vim.lsp.diagnostic.goto_prev("
      .. "{popup_opts = {border = 'single'}})<cr>"
  )
  map("n", "<space><space>", "<cmd>Telescope lsp_workspace_diagnostics<cr>")

  map("n", "<c-]>", "<cmd>lua vim.lsp.buf.definition()<cr>")
  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
  map("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
  map("n", "<space>t", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
  map("n", "<space>i", "<cmd>Telescope lsp_implementations<cr>")
  map("n", "<space>r", "<cmd>Telescope lsp_references<cr>")

  map("n", "<space>R", "<cmd>lua vim.lsp.buf.rename()<cr>")
  map("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<cr>")
  map("x", "<space>f", "<esc><cmd>lua vim.lsp.buf.range_formatting()<cr>")
  map("n", "<space>a", "<cmd>Telescope lsp_code_actions<cr>")
  map("x", "<space>a", "<esc><cmd>Telescope lsp_range_code_actions<cr>")

  map("n", "<space>w", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>")
  map("n", "<space>d", "<cmd>Telescope lsp_document_symbols<cr>")
end

local default_config = {
  on_attach = on_attach,
  handlers = {
    ["textDocument/hover"] = lsp.with(lsp.handlers.hover, { border = "single" }),
    ["textDocument/signatureHelp"] = lsp.with(
      lsp.handlers.signature_help,
      { border = "single" }
    ),
    ["textDocument/formatting"] = function(...)
      lsp.handlers["textDocument/formatting"](...)
      vim.cmd "echo 'Buffer formatted!'"
    end,
    ["textDocument/rangeFormatting"] = function(...)
      lsp.handlers["textDocument/rangeFormatting"](...)
      vim.cmd "echo 'Range formatted!'"
    end,
  },
}

for _, config in ipairs(config_mod.config) do
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

vim.cmd [[
  augroup lsp_conf_update_ui
    autocmd!
    autocmd User LspProgressUpdate lua lsp_conf.update_progress()
  augroup END

  augroup lsp_conf_cursor_diagnostics
    autocmd!
    autocmd CursorMoved * lua lsp_conf.restart_diagnostics_timer()
    autocmd User LspDiagnosticsChanged lua lsp_conf.restart_diagnostics_timer()
  augroup END
]]

return lsp_conf
