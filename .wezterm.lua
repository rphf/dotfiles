local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- Set up the default workspace upon GUI startup
wezterm.on("gui-startup", function()
	-- Spawn a window in the 'default' workspace at startup
	local tab, pane, default_window = mux.spawn_window({
		workspace = "default",
	})

	-- Set 'default' as the active workspace
	mux.set_active_workspace("default")

	-- Maximize the window
	default_window:gui_window():maximize()
end)

-- -- Update the right status bar to show the active workspace
-- wezterm.on("update-right-status", function(window)
-- 	window:set_right_status(window:active_workspace())
-- end)

-- Function to launch the ZenMaid workspace with specific tabs and panes
local function launch_zenmaid_workspace()
	local project_dir = wezterm.home_dir .. "/Workspace/pro/zenmaid"

	-- Spawn a new window in the ZenMaid workspace for the webapp
	local webapp_tab, webapp_pane_1, zenmaid_window = mux.spawn_window({
		workspace = "ZenMaid",
		cwd = project_dir .. "/zenmaid-webapp",
	})

	-- Split the first pane into multiple panes with the necessary directories
	local webapp_pane_2 = webapp_pane_1:split({
		direction = "Right",
		cwd = project_dir .. "/zenmaid-webapp/frontend",
	})
	local webapp_pane_3 = webapp_pane_1:split({
		direction = "Bottom",
		cwd = project_dir .. "/zenmaid-webapp",
	})
	local webapp_pane_4 = webapp_pane_2:split({
		direction = "Bottom",
		cwd = project_dir .. "/zenmaid-webapp",
	})

	-- Run the necessary commands in each pane
	webapp_pane_1:send_text("OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES rails s\n")
	webapp_pane_2:send_text("yarn dev\n")
	webapp_pane_3:send_text("bundle exec sidekiq\n")
	webapp_pane_4:send_text("rails c\n")

	-- Create a second tab for the zenmaid-mobile project
	local mobile_tab, mobile_pane_1 = zenmaid_window:spawn_tab({
		cwd = project_dir .. "/zenmaid-mobile",
	})

	local mobile_pane_2 = mobile_pane_1:split({
		direction = "Right",
		cwd = project_dir .. "/zenmaid-mobile",
	})

	-- Run the mobile project command in the left pane
	mobile_pane_1:send_text("yarn run start:local\n")

	-- Switch to the ZenMaid workspace and focus the first tab and pane
	mux.set_active_workspace("ZenMaid")
	zenmaid_window:gui_window():perform_action(act.ActivateTab(0), webapp_pane_1)
	zenmaid_window:gui_window():maximize()
end

-- WezTerm configuration options
local config = {}

config.window_background_opacity = 0.9
config.macos_window_background_blur = 15

-- Set the font
config.font = wezterm.font("JetBrainsMonoNL Nerd Font Mono")
config.font_size = 14.25

-- Apply the color scheme
config.color_scheme = "Tokyo Night Storm"

-- config.window_decorations = "RESIZE"
config.audible_bell = "Disabled"

-- Dim inactive panes to improve focus
config.inactive_pane_hsb = {
	brightness = 0.5,
}

-- Remove padding around the window
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.max_fps = 120

-- Disable fancy tab bar (use default tab bar)
config.use_fancy_tab_bar = false

-- Key bindings for pane and window management
config.keys = {
	-- Show launcher with ALT + L
	{ key = "l", mods = "ALT", action = wezterm.action.ShowLauncher },

	-- Split the pane vertically with CMD + U
	{ key = "u", mods = "CMD", action = act.SplitVertical },

	-- Split the pane horizontally with CMD + I
	{ key = "i", mods = "CMD", action = act.SplitHorizontal },

	-- Navigate between panes using CMD + HJKL
	{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },

	-- Close the current pane with CMD + W
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },

	-- Adjust pane size using CMD + Arrow keys
	{ key = "LeftArrow", mods = "CMD", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ key = "RightArrow", mods = "CMD", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
	{ key = "DownArrow", mods = "CMD", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
	{ key = "UpArrow", mods = "CMD", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },

	-- Clear scrollback with CMD + K
	{ key = "K", mods = "CMD", action = wezterm.action.ClearScrollback("ScrollbackAndViewport") },

	-- Show launcher for workspaces with ALT + 9
	{ key = "9", mods = "ALT", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },

	-- Switch to the next workspace with CMD + `
	{ key = "`", mods = "CMD", action = act.SwitchWorkspaceRelative(1) },

	-- Launch ZenMaid workspace with OPT + W
	{
		key = "w",
		mods = "OPT",
		action = wezterm.action_callback(function(window, pane)
			launch_zenmaid_workspace()
		end),
	},
}

local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

tabline.setup({
	options = { theme = "Tokyo Night Storm" },
	sections = {
		tabline_a = { "mode" },
		tabline_b = { "workspace" },
		tabline_c = { " " },
		tab_active = { "index", { "process", padding = { left = 0, right = 1 } } },
		tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
		tabline_x = {},
		tabline_y = {},
		tabline_z = { "hostname" },
	},
})

tabline.apply_to_config(config)

return config
