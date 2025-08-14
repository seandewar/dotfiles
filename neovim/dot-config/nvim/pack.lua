local api = vim.api
local fn = vim.fn
local pack = vim.pack

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

local function post_update_nts()
  local nts = require "nvim-treesitter"

  -- Install a minimal set of parsers. Install others via ":TSInstall".
  nts.install {
    -- Parsers are bundled with Nvim itself. Update them so nvim-treesitter's
    -- newer queries don't throw errors when using the older bundled parsers:
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
  }

  -- Update all installed parsers, including those manually ":TSInstall"ed.
  nts.update()
end

local function post_update_firenvim()
  vim.cmd.packadd { "firenvim", bang = true }
  fn["firenvim#install"](0)
end

local post_update_cbs = {} --- @type function[]?
api.nvim_create_autocmd("PackChanged", {
  group = api.nvim_create_augroup("conf_pack", {}),
  callback = function(args)
    if args.data.kind ~= "update" then
      return
    end

    --- @param f function
    local function post_update(f)
      if post_update_cbs then
        post_update_cbs[#post_update_cbs + 1] = f
      else
        f()
      end
    end

    local spec = args.data.spec
    if spec.name == "nvim-treesitter" then
      post_update(post_update_nts)
    elseif spec.name == "firenvim" then
      post_update(post_update_firenvim)
    end
  end,
})

pack.add({
  -- Colour scheme.
  { src = "https://github.com/seandewar/paragon.vim", version = "next" },

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
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
  },
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
  load = false, -- Only load when needed.
  confirm = false,
})

-- Run post-update callbacks now after vim.pack.add() has called :packadd.
for _, f in ipairs(assert(post_update_cbs)) do
  f()
end
-- After this point, post-update callbacks can be called immediately, as
-- :packadd should have already been called for all plugins.
post_update_cbs = nil

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
