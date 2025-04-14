---@class GoTestT
---@field tests_info table<string, terminal.testInfo>
---@field job_id number
---@field term_test_command_format string
---@field test_command string
---@field terminal_name string
---@field term_tester terminalTest
---@field user_command_prefix string
---@field ns_id number
---@field set_up fun(self: GoTestT, user_command_prefix: string)
---@field test_all? fun(command: string[])
---@field toggle_display? fun(self: GoTestT)
---@field load_quack_tests? fun(self: GoTestT)
---@field _clean_up_prev_job? fun(self: GoTestT)
---@field _add_golang_test? fun(self: GoTestT, entry: table)
---@field _filter_golang_output? fun(self: GoTestT, entry: table)
---@field _mark_outcome? fun(self: GoTestT, entry: table)
---@field _setup_commands? fun(self: GoTestT)
---
---@class GoTestT.Options
---@field term_test_command_format string
---@field test_command string
---@field terminal_name? string
---@field display_title? string
---@field user_command_prefix? string

---@class terminalTest
---@field terminals TerminalMultiplexer
---@field tests_info table<string, terminal.testInfo>
---@field term_test_displayer? GoTestDisplay
---@field ns_id number
---@field term_test_command_format string

---@class terminal.testInfo
---@field name string
---@field status string
---@field fail_at_line? number
---@field has_details? boolean
---@field test_bufnr number
---@field test_line number
---@field test_command string
---@field filepath string
---@field set_ext_mark boolean
---@field fidget_handle ProgressHandle

---@class TerminalTestTracker
---@field track_list terminal.testInfo[]
---@field add_test_to_tracker? fun(test_command_format: string)
---@field jump_to_tracked_test_by_index? fun(index: integer)
---@field toggle_tracked_terminal_by_index? fun(index: integer)
---@field select_delete_tracked_test? fun()
---@field reset_tracker? fun()
---@field toggle_tracker_window? fun()
---@field update_tracker_window? fun()
---@field get_test_index_under_cursor? fun(): integer
---@field jump_to_test_under_cursor? fun()
---@field toggle_terminal_under_cursor? fun()
---@field delete_test_under_cursor? fun()
---@field run_test_under_cursor? fun()
---@field _create_tracker_window? fun()
---@field _original_win_id? integer
---@field _win_id? integer
---@field _buf_id? integer
---@field _is_open boolean
---
---@class GoTestDisplay
---@field display_title string
---@field display_win number
---@field display_buf number
---@field original_test_win number
---@field original_test_buf number
---@field ns_id number
---@field tests_info  terminal.testInfo[]
---@field close_display fun(self: GoTestDisplay)
---@field toggle_term_func fun(test_name: string)
---@field rerun_in_term_func fun(test_name: string)
