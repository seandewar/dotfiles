local api = vim.api

api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("conf_treesitter", {}),
  callback = function(args)
    -- Skip if no filetype. Also, TS highlighting is already on by default for
    -- some filetypes.
    if vim.bo[args.buf].filetype == "" or vim.b[args.buf].ts_highlight then
      return
    end

    local ok, _ = pcall(vim.treesitter.start, args.buf)
    if ok then
      -- Prepend to guard against b:undo_ftplugins ending with commands that
      -- consume bars or many lines (like :autocmd, which was used by zig.vim).
      vim.b[args.buf].undo_ftplugin = "execute 'lua vim.treesitter.stop()'\n"
        .. (vim.b[args.buf].undo_ftplugin or "")
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
    "comment",
  },
}
