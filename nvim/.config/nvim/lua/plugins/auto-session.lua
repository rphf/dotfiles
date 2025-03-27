return {
  "rmagatti/auto-session",
  lazy = false,

  ---enables autocomplete for opts
  -- ---@module "auto-session"
  -- ---@type AutoSession.Config
  opts = {
    -- allowed_dirs = {  },
    show_auto_restore_notif = true,
    cwd_change_handling = true,
    log_level = "error",
    session_lens = {
      previewer = true,
    },
  },
}
