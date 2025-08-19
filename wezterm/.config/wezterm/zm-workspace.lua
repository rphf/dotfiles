local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

local M = {}

function M.setup()
  -- Launch ZM webapp workspace
  wezterm.on("launch_zm_webapp", function()
    local project_dir = wezterm.home_dir .. "/Workspace/pro/zenmaid"

    -- Check if zm workspace exists
    local zm_workspace_exists = false
    local existing_window = nil

    for _, w in ipairs(mux.all_windows()) do
      if w:get_workspace() == "zm" then
        zm_workspace_exists = true
        existing_window = w
        break
      end
    end

    local webapp_tab, webapp_pane_1, zm_window

    if zm_workspace_exists and existing_window then
      -- Switch to zm workspace and check if webapp tab exists
      mux.set_active_workspace("zm")

      for _, tab in ipairs(existing_window:tabs()) do
        if tab:get_title():find("webapp") then
          existing_window:gui_window():perform_action(act.ActivateTab(tab:tab_id()), tab:active_pane())
          return -- Exit early if webapp tab already exists
        end
      end

      -- Create new webapp tab in existing zm workspace
      webapp_tab, webapp_pane_1 = existing_window:spawn_tab({ cwd = project_dir .. "/zenmaid-webapp" })
      zm_window = existing_window
    else
      -- Create new zm workspace with webapp tab
      webapp_tab, webapp_pane_1, zm_window = mux.spawn_window({
        workspace = "zm",
        cwd = project_dir .. "/zenmaid-webapp",
      })
    end

    -- Set up webapp panes
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

    webapp_tab:set_title("term: webapp")

    webapp_pane_1:send_text("OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES bundle exec rails s\n")
    webapp_pane_2:send_text("yarn run dev\n")
    webapp_pane_3:send_text("bundle exec rails c\n")
    -- Sidekiq pane: Start Docker, run docker-compose, then start sidekiq
    webapp_pane_4:send_text(
      "if ! docker info >/dev/null 2>&1; then open -a Docker >/dev/null 2>&1 & while ! docker info >/dev/null 2>&1; do sleep 1; done; fi\n"
    )
    webapp_pane_4:send_text("docker-compose -f docker-compose.dev.yml up -d && bundle exec sidekiq\n")

    mux.set_active_workspace("zm")
    zm_window:gui_window():perform_action(act.ActivateTab(webapp_tab:tab_id()), webapp_pane_1)
    if not zm_workspace_exists then
      zm_window:gui_window():maximize()
    end
  end)

  wezterm.on("launch_zm_mobile", function()
    local project_dir = wezterm.home_dir .. "/Workspace/pro/zenmaid"

    -- Check if zm workspace exists
    local zm_workspace_exists = false
    local existing_window = nil

    for _, w in ipairs(mux.all_windows()) do
      if w:get_workspace() == "zm" then
        zm_workspace_exists = true
        existing_window = w
        break
      end
    end

    if zm_workspace_exists and existing_window then
      -- Switch to zm workspace and check if mobile tab exists
      mux.set_active_workspace("zm")

      local mobile_tab_exists = false
      for _, tab in ipairs(existing_window:tabs()) do
        if tab:get_title():find("mobile") then
          mobile_tab_exists = true
          existing_window:gui_window():perform_action(act.ActivateTab(tab:tab_id()), tab:active_pane())
          break
        end
      end

      if not mobile_tab_exists then
        -- Create new mobile tab in existing zm workspace
        local mobile_tab, mobile_pane_1 = existing_window:spawn_tab({ cwd = project_dir .. "/zenmaid-mobile" })
        local _ = mobile_pane_1:split({
          direction = "Right",
          cwd = project_dir .. "/zenmaid-mobile",
        })
        mobile_tab:set_title("term: mobile")
        mobile_pane_1:send_text("yarn run start:local\n")
      end
    else
      -- Create new zm workspace with just mobile tab
      local mobile_tab, mobile_pane_1, zm_window = mux.spawn_window({
        workspace = "zm",
        cwd = project_dir .. "/zenmaid-mobile",
      })
      local _ = mobile_pane_1:split({
        direction = "Right",
        cwd = project_dir .. "/zenmaid-mobile",
      })
      mobile_tab:set_title("term: mobile")
      mobile_pane_1:send_text("yarn run start:local\n")

      mux.set_active_workspace("zm")
      zm_window:gui_window():maximize()
    end
  end)

  -- Shutdown ZM workspace
  wezterm.on("shutdown_zm_workspace", function()
    local project_dir = wezterm.home_dir .. "/Workspace/pro/zenmaid/zenmaid-webapp"

    -- Temporary shutdown window to stop app + docker
    local shutdown_tab, shutdown_pane, shutdown_window = mux.spawn_window({
      workspace = "shutdown",
      cwd = project_dir,
    })
    shutdown_tab:set_title("Shutting down ZM...")

    shutdown_pane:send_text("cd " .. project_dir .. "\n")
    shutdown_pane:send_text("echo 'Stopping ZM processes...'\n")
    shutdown_pane:send_text("pkill -f 'zenmaid.*rails' || true\n")
    shutdown_pane:send_text("pkill -f 'sidekiq.*zenmaid' || true\n")
    shutdown_pane:send_text("pkill -f 'zenmaid.*yarn.*dev' || true\n")
    shutdown_pane:send_text("pkill -f 'zenmaid.*yarn.*start:local' || true\n")
    shutdown_pane:send_text("pkill -f 'zenmaid-webapp' || true\n")
    shutdown_pane:send_text("pkill -f 'zenmaid-mobile' || true\n")
    shutdown_pane:send_text("pkill -f 'bin/rails c' || true\n")
    shutdown_pane:send_text("echo 'Stopping docker-compose services...'\n")
    -- if you use the plugin form, swap to: docker compose -f docker-compose.dev.yml down
    shutdown_pane:send_text("docker-compose -f docker-compose.dev.yml down\n")
    shutdown_pane:send_text("echo 'Closing ZM workspace...'\n")
    shutdown_pane:send_text("sleep 1\n")
    shutdown_pane:send_text("exit\n")

    -- Give pkill/docker a moment, then close panes in the zm workspace
    wezterm.time.call_after(3, function()
      -- Hide the close churn
      mux.set_active_workspace("default")

      -- 1) Graceful: Ctrl-C then 'exit' in every pane
      for _, w in ipairs(mux.all_windows()) do
        if w:get_workspace() == "zm" then
          for _, t in ipairs(w:tabs()) do
            for _, p in ipairs(t:panes()) do
              p:send_text("\x03") -- Ctrl-C
              p:send_text("exit\n") -- close the shell
            end
          end
        end
      end

      -- 2) Backstop: if anything survived, force-kill the panes after a short delay
      wezterm.time.call_after(2, function()
        for _, w in ipairs(mux.all_windows()) do
          if w:get_workspace() == "zm" then
            for _, t in ipairs(w:tabs()) do
              for _, p in ipairs(t:panes()) do
                -- Requires wezterm CLI; kills without GUI focus
                wezterm.run_child_process({
                  "wezterm",
                  "cli",
                  "kill-pane",
                  "--pane-id",
                  tostring(p:pane_id()),
                })
              end
            end
          end
        end
      end)
    end)
  end)
end

return M
