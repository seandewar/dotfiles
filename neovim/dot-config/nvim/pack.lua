local api = vim.api
local pack = vim.pack

api.nvim_create_autocmd("PackChanged", {
  group = api.nvim_create_augroup("conf_pack", {}),
  callback = function(args)
    require("conf.pack").pack_changed(args)
  end,
})

pack.add({
  "https://github.com/tpope/vim-dispatch",
  "https://github.com/tpope/vim-repeat",
  "https://github.com/tpope/vim-surround",
  "https://github.com/tpope/vim-vinegar",

  -- Git integration.
  "https://github.com/tpope/vim-fugitive",
  "https://github.com/tpope/vim-rhubarb",

  -- Fuzzy finding via fzf.
  "https://github.com/ibhagwan/fzf-lua",

  -- Up-to-date filetype support for Zig.
  "https://github.com/ziglang/zig.vim",

  -- Tree-sitter.
  "https://github.com/nvim-treesitter/nvim-treesitter",
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    version = "main",
  },
}, {
  confirm = false,
})

pack.add({
  -- Web browser integration.
  "https://github.com/glacambre/firenvim",
}, {
  load = false, -- Only loaded when needed.
  confirm = false,
})

-- Automatically delete plugins that we no longer call vim.pack.add() for.
local inactive_plugins = vim
  .iter(pack.get())
  :filter(function(plugin)
    return not plugin.active
  end)
  :map(function(plugin)
    return plugin.spec.name
  end)
  :totable()

if #inactive_plugins > 0 then
  print "Deleting inactive plugins..."
  pack.del(inactive_plugins)
end

api.nvim_create_user_command("PackUpdate", function(args)
  pack.update(#args.fargs > 0 and args.fargs or nil, { force = args.bang })
end, {
  nargs = "*",
  complete = function(lead, _, _)
    return vim
      .iter(pack.get())
      :map(function(plugin)
        return plugin.spec.name
      end)
      :filter(function(name)
        return name:sub(1, #lead) == lead
      end)
      :totable()
  end,
  bang = true,
  bar = true,
  desc = "Update plugins managed by vim.pack",
})
