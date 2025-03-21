local api = vim.api
local fn = vim.fn
local treesitter = vim.treesitter

-- Enable TS features for supported filetypes.
-- We prepend to b:undo_ftplugins to guard against ftplugins that set values
-- ending with commands that consume bars or other lines (like :autocmd, which
-- was used by zig.vim).
api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("conf_treesitter", {}),
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "" then
      return
    end

    if treesitter.query.get(treesitter.language.get_lang(ft), "folds") then
      local folding = require "conf.folding"
      folding.enable(args.buf, folding.type.TREESITTER, true)
      vim.b[args.buf].undo_ftplugin = (
        [[execute 'lua local f = require "conf.folding" f.enable(0, f.type.TREESITTER, false)']]
        .. "\n"
        .. (vim.b[args.buf].undo_ftplugin or "")
      )
    end

    -- TS highlighting already on by default for some filetypes.
    if vim.b[args.buf].ts_highlight then
      return
    end

    local ok, _ = pcall(treesitter.start, args.buf)
    if ok then
      vim.b[args.buf].undo_ftplugin = "call v:lua.vim.treesitter.stop()\n"
        .. (vim.b[args.buf].undo_ftplugin or "")
    end
  end,
})

require("nvim-treesitter").setup {
  -- Install a minimal set of parsers. Others can be installed via :TSInstall.
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

    -- Extra parsers not bundled with Nvim:
    "cpp",
    "comment",
  },
}
