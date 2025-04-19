local api = vim.api

-- TODO: these lspconfig commands don't use vim.lsp.config yet
api.nvim_del_user_command "LspStart"
api.nvim_del_user_command "LspStop"
api.nvim_del_user_command "LspRestart"
