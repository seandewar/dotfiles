local api = vim.api
local keymap = vim.keymap

local augroup = api.nvim_create_augroup("conf_auto_foldcolumn", {})

-- Want priority on the <nowait> mapping, so it has to be defined after other
-- possibly conflicting mappings. Just remap it on each SafeState.
api.nvim_create_autocmd("SafeState", {
  group = augroup,
  callback = function()
    if api.nvim_get_mode().mode ~= "n" then
      return
    end

    keymap.set("n", "z", function()
      local win = api.nvim_get_current_win()
      local buf = api.nvim_get_current_buf()
      local save_foldcolumn = vim.wo[win][0].foldcolumn

      vim.wo[win][0].foldcolumn = "auto:9"
      api.nvim__redraw { win = win, valid = true, cursor = true }
      api.nvim_create_autocmd("SafeState", {
        group = augroup,
        once = true,
        callback = function()
          if
            not api.nvim_win_is_valid(win)
            or not api.nvim_buf_is_valid(buf)
            -- Currently vim.wo[win][0] only works for curbuf; can use a similar
            -- autocmd trick like conf.folding in other cases, but not worth it.
            or api.nvim_win_get_buf(win) ~= buf
          then
            return
          end

          vim.wo[win][0].foldcolumn = save_foldcolumn
        end,
      })

      -- "remap" is set so other mappings can be used, but we don't want to
      -- trigger ourself recursively, so unmap ourself. We'll be re-registered
      -- on the next Normal mode SafeState.
      keymap.del("n", "z")
      -- Can't use <expr>; want recursiveness.
      api.nvim_feedkeys("z", "mt", false)
    end, {
      nowait = true,
      remap = true,
    })
  end,
})
