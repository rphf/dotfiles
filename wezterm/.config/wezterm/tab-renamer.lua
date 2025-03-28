local wezterm = require("wezterm")

local apps = {
  nvim = { pattern = "nvim", prefix = "nvim: " },
  lazygit = { pattern = "lazygit", prefix = "lazygit: " },
}

local function get_dir_name(cwd)
  return tostring(cwd):gsub("^file://", ""):match("([^/]+)/?$")
end

wezterm.on("update-status", function(window)
  for _, tab in ipairs(window:mux_window():tabs()) do
    local current_title = tab:get_title()
    -- Skip if already properly named
    if not current_title:match("^(nvim|lazygit): ") then
      for _, pane in ipairs(tab:panes()) do
        local process = pane:get_foreground_process_name() or ""
        for _, cfg in pairs(apps) do
          if process:match(cfg.pattern) then
            local cwd = pane:get_current_working_dir()
            if cwd then
              tab:set_title(cfg.prefix .. get_dir_name(cwd))
              break -- Move to next tab
            end
          end
        end
      end
    end
  end
end)

return {}
