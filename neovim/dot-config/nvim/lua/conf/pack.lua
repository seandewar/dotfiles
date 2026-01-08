local fn = vim.fn

local M = {}

local function post_update_nts()
  vim.cmd.packadd "nvim-treesitter"
  local nts = require "nvim-treesitter"

  -- Install a minimal set of parsers. Install others via ":TSInstall".
  nts.install({
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
  }, { summary = true })

  -- Update all installed parsers, including those manually ":TSInstall"ed.
  nts.update(nil, { summary = true })
end

local function post_update_firenvim()
  vim.cmd.packadd { "firenvim", bang = true }
  fn["firenvim#install"](0)
end

--- @param args vim.api.keyset.create_autocmd.callback_args
function M.pack_changed(args)
  if args.data.kind ~= "update" then
    return
  end

  local spec = args.data.spec
  if spec.name == "nvim-treesitter" then
    post_update_nts()
  elseif spec.name == "firenvim" then
    post_update_firenvim()
  end
end

return M
