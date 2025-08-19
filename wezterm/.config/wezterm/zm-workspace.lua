local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

local M = {}

function M.setup()
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
                  p:send_text("\x03")      -- Ctrl-C
                  p:send_text("exit\n")    -- close the shell
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
                      "wezterm", "cli", "kill-pane", "--pane-id", tostring(p:pane_id())
                    })
                  end
                end
              end
            end
          end)
        end)
      end)

    wezterm.on("launch_zm_workspace", function()
        local project_dir = wezterm.home_dir .. "/Workspace/pro/zenmaid"

        -- Set up tabs and panes for ZM webapp
        local webapp_tab, webapp_pane_1, zm_window = mux.spawn_window({
            workspace = "zm",
            cwd = project_dir .. "/zenmaid-webapp",
        })
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
        webapp_pane_4:send_text("if ! docker info >/dev/null 2>&1; then open -a Docker >/dev/null 2>&1 & while ! docker info >/dev/null 2>&1; do sleep 1; done; fi\n")
        webapp_pane_4:send_text("docker-compose -f docker-compose.dev.yml up -d && bundle exec sidekiq\n")

        -- Set up tab for ZM mobile project
        local mobile_tab, mobile_pane_1 = zm_window:spawn_tab({ cwd = project_dir .. "/zenmaid-mobile" })
        local _ = mobile_pane_1:split({
            direction = "Right",
            cwd = project_dir .. "/zenmaid-mobile",
        })
        mobile_tab:set_title("term: mobile")
        mobile_pane_1:send_text("yarn run start:local\n")

        mux.set_active_workspace("zm")
        zm_window:gui_window():perform_action(act.ActivateTab(0), webapp_pane_1)
        zm_window:gui_window():maximize()
    end)
end

return M
