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

function util.get_current_command_map_of_panes()
    local output = tmux_command("list-panes -a -F '#{pane_id} #{pane_current_command}'")
    local map = {}
    for line in output:gmatch("[^\r\n]+") do
        local pane_id, pane_current_command = line:match("(%d+) (.+)")
        map[pane_id] = pane_current_command
    end
    return map
end

function util.find_first_non_nvim_pane()
    local map = util.get_current_command_map_of_panes()
    for pane_id, pane_current_command in pairs(map) do
        if pane_current_command ~= "nvim" then
            return pane_id
        end
    end
    return nil
end

-- Creates a new window and returns the window id and pane id of the new window
function util.create_new_window()
    local output = tmux_command("new-window -P -F '#{window_id} #{pane_id}'")
    local window_id, pane_id = output:match("(%d+) (%d+)")
    return window_id, pane_id
end

function util.tmux_change_pane(pane_id)
    tmux_command("select-pane -t " .. pane_id)
end

return util
