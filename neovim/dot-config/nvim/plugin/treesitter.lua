local api = vim.api
local keymap = vim.keymap
local treesitter = vim.treesitter

api.nvim_create_user_command("TSStart", function(_)
  treesitter.start()
end, {
  bar = true,
  desc = "Start tree-sitter highlighting in the current buffer",
})
api.nvim_create_user_command("TSStop", function(_)
  treesitter.stop()
end, {
  bar = true,
  desc = "Stop tree-sitter highlighting in the current buffer",
})

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

    local lang = treesitter.language.get_lang(ft)
    if lang then
      local ok, result = pcall(treesitter.query.get, lang, "folds")
      if ok and result then
        local folding = require "conf.folding"
        folding.enable(args.buf, folding.type.TREESITTER)
        vim.b[args.buf].undo_ftplugin = (
          "execute 'lua local f = require ''conf.folding'' "
          .. "f.enable(0, f.type.TREESITTER, false)'\n"
          .. (vim.b[args.buf].undo_ftplugin or "")
        )
      end

      ok, result = pcall(treesitter.query.get, lang, "textobjects")
      if ok and result then
        local captures_set = vim.iter(result.captures):fold({}, function(acc, c)
          acc[c] = true
          return acc
        end)

        local function define_move_map(lhs, capture_name, goto_fn_name)
          if not captures_set[capture_name] then
            return
          end

          keymap.set({ "n", "x", "o" }, lhs, function()
            require("nvim-treesitter-textobjects.move")[goto_fn_name](
              "@" .. capture_name,
              "textobjects"
            )
          end, {
            buffer = args.buf,
            desc = "Tree-sitter " .. goto_fn_name .. " of @" .. capture_name,
          })
          vim.b[args.buf].undo_ftplugin = ("unmap <buffer> %s\n"):format(lhs)
            .. (vim.b[args.buf].undo_ftplugin or "")
        end

        local function define_select_map(lhs, capture_name)
          if not captures_set[capture_name] then
            return
          end

          keymap.set({ "x", "o" }, lhs, function()
            require("nvim-treesitter-textobjects.select").select_textobject(
              "@" .. capture_name,
              "textobjects"
            )
          end, {
            buffer = args.buf,
            desc = "Tree-sitter select_textobject of @" .. capture_name,
          })
          vim.b[args.buf].undo_ftplugin = ("unmap <buffer> %s\n"):format(lhs)
            .. (vim.b[args.buf].undo_ftplugin or "")
        end

        define_move_map("]m", "function.outer", "goto_next_start")
        define_move_map("[m", "function.outer", "goto_previous_start")
        define_move_map("]M", "function.outer", "goto_next_end")
        define_move_map("[M", "function.outer", "goto_previous_end")

        define_move_map("][", "class.outer", "goto_next_start")
        define_move_map("[[", "class.outer", "goto_previous_start")
        define_move_map("]]", "class.outer", "goto_next_end")
        define_move_map("[]", "class.outer", "goto_previous_end")

        define_select_map("af", "function.outer")
        define_select_map("if", "function.inner")
        define_select_map("ac", "class.outer")
        define_select_map("ic", "class.inner")
      end
    end

    -- TS highlighting already on by default for some filetypes.
    if not vim.b[args.buf].ts_highlight then
      local ok, _ = pcall(treesitter.start, args.buf)
      if ok then
        vim.b[args.buf].undo_ftplugin = "call v:lua.vim.treesitter.stop()\n"
          .. (vim.b[args.buf].undo_ftplugin or "")
      end
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

require("nvim-treesitter-textobjects").setup {
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
}
