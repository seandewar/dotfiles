return {
  --- @param config vim.lsp.ClientConfig
  before_init = function(_, config)
    if vim.system({ "cargo", "clippy", "--version" }):wait().code == 0 then
      config.settings =
        { ["rust-analyzer"] = { check = { command = "clippy" } } }
    end
  end,
}
