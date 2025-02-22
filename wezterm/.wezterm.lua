local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

local config = {}

-- Appearance Settings
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono")
config.font_size = 14.25
config.color_scheme = "Tokyo Night Storm"
config.macos_window_background_blur = 15
config.window_background_opacity = 0.9
config.inactive_pane_hsb = { brightness = 0.5 }
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
config.colors = {
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
	{ key = "p", mods = "CMD", action = wezterm.action.ShowLauncher },
	{ key = "u", mods = "CMD", action = act.SplitVertical },
	{ key = "i", mods = "CMD", action = act.SplitHorizontal },
	{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "`", mods = "CMD", action = act.SwitchWorkspaceRelative(1) },
	{ key = "LeftArrow", mods = "CMD", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ key = "RightArrow", mods = "CMD", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
	{ key = "DownArrow", mods = "CMD", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
	{ key = "UpArrow", mods = "CMD", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
	{ key = "K", mods = "CMD", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },

	-- ZenMaid workspace launch
	{
		key = "z",
		mods = "OPT",
		action = wezterm.action.EmitEvent("launch_zenmaid_workspace"),
	},
}

-- Workspace Configuration (ZenMaid Workspace)
wezterm.on("launch_zenmaid_workspace", function()
	local project_dir = wezterm.home_dir .. "/Workspace/pro/zenmaid"

	-- Set up tabs and panes for ZenMaid webapp
	local webapp_tab, webapp_pane_1, zenmaid_window = mux.spawn_window({
		workspace = "zenmaid",
		cwd = project_dir .. "/zenmaid-webapp",
	})
	local webapp_pane_2 = webapp_pane_1:split({ direction = "Right", cwd = project_dir .. "/zenmaid-webapp/frontend" })
	local webapp_pane_3 = webapp_pane_1:split({ direction = "Bottom", cwd = project_dir .. "/zenmaid-webapp" })
	local webapp_pane_4 = webapp_pane_2:split({ direction = "Bottom", cwd = project_dir .. "/zenmaid-webapp" })

	webapp_pane_1:send_text("OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES bundle exec rails s\n")
	webapp_pane_2:send_text("yarn dev\n")
	webapp_pane_3:send_text("bundle exec rails c\n")
	webapp_pane_4:send_text("bundle exec sidekiq\n")

	-- Set up tab for ZenMaid mobile project
	local mobile_tab, mobile_pane_1 = zenmaid_window:spawn_tab({ cwd = project_dir .. "/zenmaid-mobile" })
	local mobile_pane_2 = mobile_pane_1:split({ direction = "Right", cwd = project_dir .. "/zenmaid-mobile" })
	mobile_pane_1:send_text("yarn run start:local\n")

	mux.set_active_workspace("zenmaid")
	zenmaid_window:gui_window():perform_action(wezterm.action.ActivateTab(0), webapp_pane_1)
	zenmaid_window:gui_window():maximize()
end)

-- Update the right status bar to show the active workspace
wezterm.on("update-right-status", function(window, pane)
	window:set_right_status(window:active_workspace())
end)

-- GUI Startup Settings
wezterm.on("gui-startup", function()
	local _, _, default_window = wezterm.mux.spawn_window({ workspace = "default" })
	wezterm.mux.set_active_workspace("default")
	default_window:gui_window():maximize()
end)

return config
