local api = vim.api
local fn = vim.fn

local ns = api.nvim_create_namespace "conf_folding_virtual_text"

---@class ExtmarkInfo
---@field buf integer
---@field start_lnum integer
---@field end_lnum integer
---@field level integer
---@field cursor_extmark_id integer
local extmark_info ---@type ExtmarkInfo?

local function clear_extmarks()
  if extmark_info then
    api.nvim_buf_clear_namespace(extmark_info.buf, ns, 0, -1)
    extmark_info = nil
  end
end

local function update_extmarks()
  if not vim.wo[0][0].foldenable or vim.wo[0][0].foldcolumn ~= "0" then
    clear_extmarks()
    return -- Folding disabled or there's already a fold column.
  end
  if api.nvim_get_mode().mode ~= "n" then
    clear_extmarks()
    return -- Fold commands mostly only relevant in Normal mode.
  end

  local cursor_level = fn.foldlevel "."
  if cursor_level == 0 or fn.foldclosed "." ~= -1 then
    clear_extmarks()
    return -- No fold or closed fold.
  end

  ---@param lnum integer
  ---@param cursor_lnum integer
  ---@param start_lnum integer
  ---@param end_lnum integer
  ---@param id integer?
  local function set_extmark(lnum, cursor_lnum, start_lnum, end_lnum, id)
    local text = "│"
    if lnum == cursor_lnum then
      text = tostring(cursor_level)
    elseif lnum == start_lnum then
      text = "┐"
    elseif lnum == end_lnum then
      text = "┘"
    end

    return api.nvim_buf_set_extmark(0, ns, lnum - 1, 0, {
      id = id,
      virt_text = { { text, "FoldColumn" } },
      virt_text_pos = "eol_right_align",
      undo_restore = false,
      invalidate = true,
      priority = 65535, -- Always right-most
    })
  end

  local curbuf = api.nvim_get_current_buf()
  local cursor_lnum = api.nvim_win_get_cursor(0)[1]
  if
    extmark_info
    and curbuf == extmark_info.buf
    and cursor_lnum >= extmark_info.start_lnum
    and cursor_lnum <= extmark_info.end_lnum
    and cursor_level == extmark_info.level
  then
    -- Still within the same fold and it's valid. Just adjust two extmarks.
    local old_cursor_row = api.nvim_buf_get_extmark_by_id(
      curbuf,
      ns,
      extmark_info.cursor_extmark_id,
      {}
    )[1]
    local cursor_extmark_id = vim.tbl_get(
      api.nvim_buf_get_extmarks(
        curbuf,
        ns,
        { cursor_lnum - 1, 0 },
        { cursor_lnum - 1, 0 },
        { limit = 1 }
      ),
      1,
      1
    )

    -- TextChanged (which invalides the extmarks) should happen before
    -- SafeState, so the extmarks should be where we expect them, but if not,
    -- skip this and revalidate them.
    if old_cursor_row and cursor_extmark_id then
      set_extmark(
        old_cursor_row + 1,
        cursor_lnum,
        extmark_info.start_lnum,
        extmark_info.end_lnum,
        cursor_extmark_id
      )
      set_extmark(
        cursor_lnum,
        cursor_lnum,
        extmark_info.start_lnum,
        extmark_info.end_lnum,
        extmark_info.cursor_extmark_id
      )
      return
    end
  end

  clear_extmarks()

  -- Find the start and end of the open fold. Unlike for closed folds, Vim
  -- doesn't provide an interface for this, and the naive approach of using
  -- foldlevel() to find the range doesn't work if it's adjacent to a different
  -- fold of the same level. Evaluating &foldexpr doesn't work if &foldmethod is
  -- not "expr" (and should be done in the script context in which it was set).
  -- Temporarily jumping to the start/end with [z/]z jumps outside the fold if
  -- we're on the first/last line.
  --
  -- Instead, temporarily close the fold and use foldclosed*() to find the
  -- range, while avoiding side-effects.
  local start_lnum, end_lnum
  vim._with({ noautocmd = true }, function()
    local view = fn.winsaveview()
    -- Non-zero &foldminlines may stop us from folding.
    local save_foldminlines = vim.wo[0][0].foldminlines
    vim.wo[0][0].foldminlines = 0

    vim.cmd "normal! zc"
    start_lnum = fn.foldclosed "."
    end_lnum = fn.foldclosedend "."
    vim.cmd "normal! zo"

    vim.wo[0][0].foldminlines = save_foldminlines
    fn.winrestview(view)
  end)

  local cursor_extmark_id
  for lnum = start_lnum, end_lnum do
    local extmark_id = set_extmark(lnum, cursor_lnum, start_lnum, end_lnum)
    if lnum == cursor_lnum then
      cursor_extmark_id = extmark_id
    end
  end

  extmark_info = {
    buf = curbuf,
    start_lnum = start_lnum,
    end_lnum = end_lnum,
    level = cursor_level,
    cursor_extmark_id = cursor_extmark_id,
  }
end

local augroup = api.nvim_create_augroup("conf_folding_virtual_text", {})

api.nvim_create_autocmd("TextChanged", {
  group = augroup,
  callback = clear_extmarks,
})
api.nvim_create_autocmd("ModeChanged", {
  group = augroup,
  pattern = "n:*",
  callback = clear_extmarks,
})
api.nvim_create_autocmd("OptionSet", {
  group = augroup,
  pattern = "fold*",
  callback = clear_extmarks,
})
api.nvim_create_autocmd("SafeState", {
  group = augroup,
  callback = update_extmarks,
})
