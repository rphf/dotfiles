require("tab-renamer")
require("zm-workspace").setup()
local wezterm = require("wezterm") -- --[[@as Wezterm]] TODO: Fix type annotation for wezterm (using lazydev)
local act = wezterm.action
-- local log = wezterm.log_info

local config = {}

-- Appearance Settings
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono")
config.font_size = 12.5
config.color_scheme = "Tokyo Night Storm"
config.macos_window_background_blur = 15
config.window_background_opacity = 0.9
config.inactive_pane_hsb = { brightness = 0.5 }
config.window_padding = { left = 10, right = 10, top = 0, bottom = 0 }
config.tab_max_width = 40
config.colors = {
  cursor_bg = "7aa2f7",
  cursor_border = "7aa2f7",
  tab_bar = {
    background = "rgba(0,0,0,0.5)",
  },
}
config.window_decorations = "RESIZE"
config.max_fps = 120
config.use_fancy_tab_bar = false

-- General Settings
config.audible_bell = "Disabled"

-- Key Bindings
config.keys = {
  { key = "p", mods = "CMD", action = act.ShowLauncher },
  { key = "u", mods = "CMD", action = act.SplitVertical },
  { key = "i", mods = "CMD", action = act.SplitHorizontal },
  { key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
  { key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "`", mods = "CMD", action = act.SwitchWorkspaceRelative(1) },
  { key = "h", mods = "CTRL", action = act.ActivateTabRelative(-1) },
  { key = "l", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "o", mods = "CMD", action = act.TogglePaneZoomState },
  -- Move tabs
  { key = "LeftArrow", mods = "CMD", action = wezterm.action({ MoveTabRelative = -1 }) },
  { key = "RightArrow", mods = "CMD", action = wezterm.action({ MoveTabRelative = 1 }) },
  -- Resize panes
  { key = "LeftArrow", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "RightArrow", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "DownArrow", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "UpArrow", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  -- ZM workspace
  { key = "z", mods = "OPT", action = act.EmitEvent("launch_zm_webapp") },
  { key = "m", mods = "OPT", action = act.EmitEvent("launch_zm_mobile") },
  { key = "z", mods = "OPT|SHIFT", action = act.EmitEvent("shutdown_zm_workspace") },
}

wezterm.on("update-right-status", function(window)
  local workspace_name = window:active_workspace()
  local workspace_count = #wezterm.mux.get_workspace_names()
  local tab = window:active_tab()
  local panes = tab:panes_with_info()

  local zoomed = false
  for _, pane_info in ipairs(panes) do
    if pane_info.is_zoomed then
      zoomed = true
      break
    end
  end

  window:set_right_status(wezterm.format({
    { Text = zoomed and "📌 · " or "" },
    { Text = workspace_name .. " " },
    { Text = workspace_count > 1 and ("· " .. workspace_count .. " 󰕰 ") or "" },
  }))
end)

-- GUI Startup Settings
wezterm.on("gui-startup", function()
  local _, _, default_window = wezterm.mux.spawn_window({ workspace = "default" })
  wezterm.mux.set_active_workspace("default")
  default_window:gui_window():maximize()
end)

return config
