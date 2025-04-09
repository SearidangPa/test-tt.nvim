local M = {}
local make_notify = require('mini.notify').make_notify {}
local display = require 'raw_dog.display'

---@class gotest.State
---@field tracker_win number
---@field tracker_buf number
---@field original_win number
---@field original_buf number
---@field tests table<string, gotest.TestInfo>
---@field job_id number
---@field ns number
---@field last_update number
M.tracker_state = {
  tracker_win = -1,
  tracker_buf = -1,
  original_win = -1,
  original_buf = -1,
  tests = {},
  job_id = -1,
  ns = -1,
}

---@class gotest.TestInfo
---@field name string
---@field package string
---@field full_name string
---@field fail_at_line number
---@field output string[]
---@field status string "running"|"pass"|"fail"|"paused"|"cont"|"start"
---@field file string

M.clean_up_prev_job = function(job_id)
  if job_id ~= -1 then
    make_notify(string.format('stopping job: %d', job_id))
    vim.fn.jobstop(job_id)
    vim.diagnostic.reset()
  end
end

local ignored_actions = {
  skip = true,
}

local action_state = {
  pause = true,
  cont = true,
  start = true,
  fail = true,
  pass = true,
}

local make_key = function(entry)
  assert(entry.Package, 'Must have package name' .. vim.inspect(entry))
  if not entry.Test then
    return entry.Package
  end
  assert(entry.Test, 'Must have test name' .. vim.inspect(entry))
  return string.format('%s/%s', entry.Package, entry.Test)
end

local add_golang_test = function(test_state, entry)
  local key = make_key(entry)
  test_state.tests[key] = {
    name = entry.Test or 'Package Test',
    package = entry.Package,
    full_name = key,
    fail_at_line = 0,
    output = {},
    status = 'running',
    file = '',
  }
end

local add_golang_output = function(test_state, entry)
  assert(test_state.tests, vim.inspect(test_state))
  local key = make_key(entry)
  local test = test_state.tests[key]

  if not test then
    return
  end

  local trimmed_output = vim.trim(entry.Output)
  table.insert(test.output, trimmed_output)

  local file, line = string.match(trimmed_output, '([%w_%-]+%.go):(%d+):')
  if file and line then
    test.fail_at_line = tonumber(line)
    test.file = file
  end

  if trimmed_output:match '^--- FAIL:' then
    test.status = 'fail'
  end
end

local mark_outcome = function(test_state, entry)
  local key = make_key(entry)
  local test = test_state.tests[key]

  if not test then
    return
  end
  -- Explicitly set the status based on the Action
  test.status = entry.Action
end

M.run_test_all = function(command)
  -- Reset test state
  M.tracker_state.tests = {}

  -- Set up tracker buffer
  display.setup_tracker_buffer()

  -- Clean up previous job
  M.clean_up_prev_job(M.tracker_state.job_id)

  M.tracker_state.job_id = vim.fn.jobstart(command, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      if not data then
        return
      end

      for _, line in ipairs(data) do
        if line == '' then
          goto continue
        end

        local success, decoded = pcall(vim.json.decode, line)
        if not success or not decoded then
          goto continue
        end

        if ignored_actions[decoded.Action] then
          goto continue
        end

        if decoded.Action == 'run' then
          add_golang_test(M.tracker_state, decoded)
          vim.schedule(function() display.update_tracker_buffer() end)
          goto continue
        end

        if decoded.Action == 'output' then
          if decoded.Test or decoded.Package then
            add_golang_output(M.tracker_state, decoded)
          end
          goto continue
        end

        -- Handle pause, cont, and start actions
        if action_state[decoded.Action] then
          mark_outcome(M.tracker_state, decoded)
          vim.schedule(function() display.update_tracker_buffer() end)
          goto continue
        end

        ::continue::
      end
    end,
    on_exit = function()
      vim.schedule(function() display.update_tracker_buffer() end)
    end,
  })
end

vim.api.nvim_create_user_command('GoTestAll', function()
  local command = { 'go', 'test', './...', '-json', '-v' }
  M.run_test_all(command)
end, {})

vim.api.nvim_create_user_command('GoTestTrackerToggle', function()
  if vim.api.nvim_win_is_valid(M.tracker_state.tracker_win) then
    M.close_tracker()
  else
    display.setup_tracker_buffer()
  end
end, {})

return M
