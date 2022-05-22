local api = vim.api

vim.fn["conf#statusline#define_component"]("lsp", function(curwin, stlwin)
  local conf_lsp = package.loaded["conf.lsp"]
  return conf_lsp ~= nil and conf_lsp.statusline(curwin, stlwin) or ""
end)

api.nvim_create_autocmd("User", {
  group = api.nvim_create_augroup("conf_lsp_progress", {}),
  pattern = "LspProgressUpdate",
  callback = function()
    require("conf.lsp").update_progress()
  end,
})

-- LspAttach, LspDetach needs Nvim 0.8
if vim.fn.has "nvim-0.8" == 0 then
  return
end

local attach_group = api.nvim_create_augroup("conf_lsp_attach_detach", {})

api.nvim_create_autocmd("LspAttach", {
  group = attach_group,
  callback = function()
    require("conf.lsp").attach_buffer()
  end,
})
api.nvim_create_autocmd("LspDetach", {
  group = attach_group,
  callback = function(args)
    require("conf.lsp").detach_buffer(args)
  end,
})
