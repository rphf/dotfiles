local wezterm = require("wezterm")

local function is_nvim_running(pane)
  local process = pane:get_foreground_process_name()
  return process and process:match("nvim") ~= nil
end

local function is_lazygit_running(pane)
  local process = pane:get_foreground_process_name()
  return process and process:match("lazygit") ~= nil
end

local function get_dir_name(cwd_uri)
  local cwd = tostring(cwd_uri)
  return cwd:match("([^/]+)/?$") or cwd
end

wezterm.on("update-status", function(window)
  for _, tab in ipairs(window:mux_window():tabs()) do
    for _, pane in ipairs(tab:panes()) do
      if is_nvim_running(pane) then
        local cwd = pane:get_current_working_dir()
        if cwd then
          tab:set_title("nvim: " .. get_dir_name(cwd))
          break -- Stop checking other panes once nvim is found
        end
      end
      if is_lazygit_running(pane) then
        local cwd = pane:get_current_working_dir()
        if cwd then
          tab:set_title("lazygit: " .. get_dir_name(cwd))
          break -- Stop checking other panes once nvim is found
        end
      end
    end
  end
end)

return {}
