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

-- Enable TS features for supported filetypes if the parser is installed.
-- We prepend to b:undo_ftplugins to guard against ftplugins that set values
-- ending with commands that consume bars or other lines (like :autocmd, which
-- was used by zig.vim).
api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("conf_treesitter", {}),
  callback = function(args)
    local lang = treesitter.language.get_lang(vim.bo[args.buf].filetype)
    if
      not lang
      or #api.nvim_get_runtime_file(("parser/%s.*"):format(lang), false) == 0
    then
      return
    end

    if treesitter.query.get(lang, "folds") then
      local folding = require "conf.folding"
      folding.enable(args.buf, folding.type.TREESITTER)

      vim.b[args.buf].undo_ftplugin = (
        "execute 'lua local f = require ''conf.folding'' "
        .. "f.enable(0, f.type.TREESITTER, false)'\n"
        .. (vim.b[args.buf].undo_ftplugin or "")
      )
    end

    local to_query = treesitter.query.get(lang, "textobjects")
    if to_query then
      local captures_set = vim.iter(to_query.captures):fold({}, function(acc, c)
        acc[c] = true
        return acc
      end)

      -- Seems nvim-treesitter-textobjects implicitly assumes that the buffer
      -- is already parsed (and the tree is up-to-date). That may not be true
      -- if, for example, tree-sitter highlighting is disabled.
      local function parse_curbuf()
        assert(treesitter.get_parser(0, lang)):parse()
      end

      local function define_move_map(lhs, capture_name, goto_fn_name)
        if not captures_set[capture_name] then
          return
        end

        keymap.set({ "n", "x", "o" }, lhs, function()
          parse_curbuf()
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
          parse_curbuf()
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

    if
      -- TS highlighting already on by default for some filetypes.
      not vim.b[args.buf].ts_highlight
      -- Don't do it for Vim script, as it's hit-or-miss.
      and lang ~= "vim"
      and treesitter.query.get(lang, "highlights")
    then
      vim.treesitter.start(args.buf, lang)

      vim.b[args.buf].undo_ftplugin = "call v:lua.vim.treesitter.stop()\n"
        .. (vim.b[args.buf].undo_ftplugin or "")
    end
  end,
})

require("nvim-treesitter-textobjects").setup {
  select = {
    lookahead = true,
  },
  move = {
    set_jumps = true,
  },
}
