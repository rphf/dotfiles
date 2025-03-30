local wezterm = require("wezterm")
-- local log = wezterm.log_info

local apps = {
  { process_name = "nvim", prefix = "nvim: " },
  { process_name = "lazygit", prefix = "lazygit: " },
}

local function get_dir_name(cwd)
  return tostring(cwd):gsub("^file://", ""):match("([^/]+)/?$")
end

local function process_basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab)
  local tab_title_prefix = nil
  local app_cwd = nil

  -- Check all panes in the tab for matching processes
  for _, pane in ipairs(tab.panes) do
    local process = pane.foreground_process_name
    local pane_cwd = pane.current_working_dir

    for _, app in pairs(apps) do
      if process:match(app.process_name) then
        tab_title_prefix = app.prefix
        app_cwd = pane_cwd -- Use the pane's CWD where the app is running
        break
      end
    end
    if tab_title_prefix then
      break
    end
  end

  local title = nil

  if tab_title_prefix then
    title = tab_title_prefix .. get_dir_name(app_cwd)
  else
    title = process_basename(tab.active_pane.foreground_process_name)
  end

  return " " .. tab.tab_index + 1 .. ". " .. title .. " "
end)

return {}
