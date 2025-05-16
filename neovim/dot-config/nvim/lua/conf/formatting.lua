local api = vim.api
local log = vim.log

local M = {}

--- @param cmd string[]
--- @param start_lnum integer?
--- @param end_lnum integer?
--- @param timeout_ms integer?
--- @return integer
function M.cmd_formatexpr(cmd, start_lnum, end_lnum, timeout_ms)
  if vim.v.char ~= "" then
    return 1 -- Was invoked automatically; use internal formatter.
  end

  start_lnum = start_lnum or vim.v.lnum
  end_lnum = end_lnum or start_lnum + vim.v.count - 1
  if end_lnum < start_lnum then
    return 0
  end
  timeout_ms = timeout_ms or 5000
  local name = cmd[1]

  -- Will format asynchronously, so save these values now.
  local buf = api.nvim_get_current_buf()
  local changedtick = api.nvim_buf_get_changedtick(buf)
  local lines = api.nvim_buf_get_lines(buf, start_lnum - 1, end_lnum, true)

  --- @param out vim.SystemCompleted
  local function exit_cb(out)
    if not api.nvim_buf_is_valid(buf) then
      return
    elseif out.code ~= 0 then
      local msg = ("%s failed with code %d"):format(name, out.code)
      if out.stderr ~= "" then
        msg = ("%s: %s"):format(msg, out.stderr)
      end
      vim.notify(msg, log.levels.ERROR)
      return
    elseif api.nvim_buf_get_changedtick(buf) ~= changedtick then
      vim.notify("Buffer modified during formatting; skipping", log.levels.WARN)
      return
    end

    local new_lines = vim.split(out.stdout, "\n", { plain = true })
    if new_lines[#new_lines] == "" then
      -- Strip trailing NL. Let Nvim handle that. (e.g: &endofline)
      new_lines[#new_lines] = nil
    end

    local function lines_unchanged()
      if #lines ~= #new_lines then
        return false
      end
      for i = 1, #lines do
        if lines[i] ~= new_lines[i] then
          return false
        end
      end
      return true
    end

    local msg = ("%s formatted %d line%s"):format(
      name,
      #lines,
      #lines > 1 and "s" or ""
    )
    if lines_unchanged() then -- Avoids unnecessary undo blocks, etc.
      msg = ("%s (no changes)"):format(msg)
    else
      api.nvim_buf_set_lines(buf, start_lnum - 1, end_lnum, true, new_lines)
    end

    if out.stderr ~= "" then
      msg = ("%s: %s"):format(msg, out.stderr)
    end
    vim.notify(msg, log.levels.INFO)
  end

  local ok, rv = pcall(vim.system, cmd, {
    -- Don't send as a list, as that results in NL being written at the end.
    stdin = table.concat(lines, "\n"),
    timeout = timeout_ms,
  }, vim.schedule_wrap(exit_cb))
  if not ok then
    vim.notify(("Failed to spawn %s: %s"):format(name, rv), log.levels.ERROR)
  end
  return 0
end

return M
