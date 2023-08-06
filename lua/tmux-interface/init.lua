local util = require 'tmux-interface.util'

local M = {}

local config = {
    last_tmux_window_id_file_path = nil,
}

local last_non_nvim_win = nil

local function is_TMUX_env_present()
    return os.getenv("TMUX") ~= nil and os.getenv("TMUX") ~= ""
end

-- select or create a new window in tmux which doesn't have a nvim instance running
function M.select_non_nvim_window()
    if is_TMUX_env_present() == false then
        return
    end

    last_non_nvim_win = util.read_last_tmux_window_id_from_file(config.last_tmux_window_id_file_path)
    if last_non_nvim_win == nil or util.is_window_alive(last_non_nvim_win) == false then
        last_non_nvim_win = util.find_first_non_nvim_window()
    end
    if last_non_nvim_win == nil then
        last_non_nvim_win = util.create_new_window()
    end
    util.select_window(last_non_nvim_win)
end

function M.select_next_winodw()
    if is_TMUX_env_present() == false then
        return
    end

    util.select_next_window()
end


function M.select_previous_winodw()
    if is_TMUX_env_present() == false then
        return
    end

    util.select_previous_window()
end

local function create_command(command_name, func, args)
    vim.api.nvim_create_user_command(command_name, function(...) func(args) end, {})
end

function M.setup(user_config)
    config.last_tmux_window_id_file_path = user_config.last_tmux_window_id_file_path
    create_command("TmuxSelectNonNvimWindow", M.select_non_nvim_window, {})
    create_command("TmuxSelectNextWindow", M.select_next_winodw, {})
    create_command("TmuxSelectPreviousWindow", M.select_previous_winodw, {})
end

return M
