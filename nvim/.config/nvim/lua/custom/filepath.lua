local M = {}

function M.get_formatted_file_path()
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    return ""
  end
  -- local cwd = vim.fn.getcwd()
  -- local relative_path = file_path:sub(#cwd + 2)

  if file_path:sub(1, 1) == "/" then
    file_path = file_path:sub(2)
  end

  return file_path:gsub("/", " > ")
end

-- Set up winbar display
function M.setup()
  vim.api.nvim_set_hl(0, "WinBar", { fg = "#41a6b5", bg = "NONE" })
  vim.api.nvim_set_hl(0, "WinBarNC", { fg = "#41a6b5", bg = "NONE" })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = "*",
    callback = function()
      local path = M.get_formatted_file_path()
      vim.wo.winbar = path ~= "" and ("%%#WinBar#%s%%*"):format(path) or ""
    end,
  })
end

return M
