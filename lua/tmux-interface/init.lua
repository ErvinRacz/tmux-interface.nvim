local util = require 'tmux-interface.util'

local M = {}

local last_non_nvim_win = nil

-- select or create a new window in tmux which doesn't have a nvim instance running
function M.select_non_nvim_window()
    if last_non_nvim_win == nil or util.is_window_alive(last_non_nvim_win) == false then
        last_non_nvim_win = util.find_first_non_nvim_window()
    end
    if last_non_nvim_win == nil then
        last_non_nvim_win = util.create_new_window()
    end
    util.select_window(last_non_nvim_win)
end

local function create_command(command_name, func, args)
    vim.api.nvim_create_user_command(command_name, function(...) func(args) end, {})
end

function M.setup()
    create_command("TmuxSelectNonNvimWindow", M.select_non_nvim_window, {})
end

return M
