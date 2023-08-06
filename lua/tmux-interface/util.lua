local util = {}

-- send the tmux command to the server running on the socket
-- given by the environment variable $TMUX
--
-- the check if tmux is actually running (so the variable $TMUX is
-- not nil) is made before actually calling this function
local function tmux_command(command)
    local tmux_socket = vim.fn.split(vim.env.TMUX, ',')[1]
    return vim.fn.system("tmux -S " .. tmux_socket .. " " .. command)
end

function util.get_current_session()
    local output = tmux_command("display-message -p '#{session_id} #{session_name}'")
    return output:match("(%$%d+) (.+)")
end

-- returns a map of the commands that are running in the panes of the current session
function util.get_current_command_map_of_windows()
    local current_session_id, _ = util.get_current_session()
    local output = tmux_command(
        "list-panes -a -F '#{session_id} #{session_name} #{window_id} #{window_name} #{pane_current_command}'")
    local map = {}
    for line in output:gmatch("[^\r\n]+") do
        local session_id, _, window_id, _, pane_current_command = line:match(
            "^(%$%d+) (.+) (%@%d+) (.+) (.+)$")
        if (current_session_id == session_id) then
            map[window_id] = pane_current_command
        end
    end
    return map
end

function util.find_first_non_nvim_window()
    local map = util.get_current_command_map_of_windows()
    for window_id, pane_current_command in pairs(map) do
        if pane_current_command ~= "nvim" then
            return window_id
        end
    end
    return nil
end

-- Creates a new window and returns the window id and pane id of the new window
function util.create_new_window()
    local output = tmux_command("new-window -P -F '#{window_id}'")
    local window_id = output:match("(%@%d+)")
    return window_id
end

-- Checks if the window with the given window id is still alive
function util.is_window_alive(window_id)
    local output = tmux_command("list-windows -F '#{window_id}'")
    for line in output:gmatch("[^\r\n]+") do
        if line == window_id then
            return true
        end
    end
    return false
end

function util.select_window(window_id)
    tmux_command("select-window -t " .. window_id)
end

-- Read the last active tmux window ID from a file e.g. /tmp/tmux-interface-last-window-id
function util.read_last_tmux_window_id_from_file(path)
    local file = io.open(path, "r")
    if file == nil then
        return nil
    end
    local window_id = file:read("*all")
    window_id = window_id:match("(%@%d+)")
    file:close()

    return window_id
end

function util.select_next_window()
    tmux_command("select-window -n")
end


function util.select_previous_window()
    tmux_command("select-window -p")
end

return util
