local api = vim.api
local start = vim.treesitter.start

vim.treesitter.start = function(bufnr, ...)
  -- Treesitter performance is a bit hit-or-miss for larger files, especially
  -- those with lots of injections.
  if api.nvim_buf_line_count(bufnr or 0) < 2000 then
    start(bufnr, ...)
  end
end

api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("conf_treesitter", {}),
  callback = function(args)
    -- Treesitter highlighting is enabled by default for some filetypes (plus it
    -- may already be on).
    if not vim.b.ts_highlight then
      pcall(vim.treesitter.start, args.buf)
    end
  end,
})

require("nvim-treesitter").setup {
  -- Install a minimal set of parsers.
  -- Others can be installed on-demand with :TSInstall
  ensure_install = {
    -- Following parsers are bundled with Nvim 0.10 itself, and need to be
    -- updated by nvim-treesitter so that nvim-treesitter's newer queries do not
    -- throw errors with the older Nvim parsers:
    "c",
    "lua",
    "markdown",
    "markdown_inline",
    "query",
    "vim",
    "vimdoc",

    -- These are extra parsers not bundled with Nvim:
    "cpp",
    -- "comment", -- TODO: is slow.
  },
}
