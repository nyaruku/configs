local M = {}

local uv = vim.loop

-- Recursively search for compile_commands.json in subdirectories
local function find_compile_commands(start_dir, depth)
  depth = depth or 0
  if depth > 5 then return nil end  -- max depth to prevent infinite recursion

  local handle = uv.fs_scandir(start_dir)
  if handle then
    while true do
      local name, type = uv.fs_scandir_next(handle)
      if not name then break end
      local fullpath = start_dir .. "/" .. name
      if name == "compile_commands.json" and type == "file" then
        return start_dir
      elseif type == "directory" then
        local found = find_compile_commands(fullpath, depth + 1)
        if found then return found end
      end
    end
  end

  -- Try parent directory
  local parent = start_dir:match("(.+)/[^/]+$")
  if parent and parent ~= start_dir then
    return find_compile_commands(parent, depth)
  end

  return nil
end

function M.setup()
  local lspconfig = require("lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local compile_dir = find_compile_commands(vim.fn.expand("%:p:h"))
  local clangd_cmd = {
    "clangd",
    "--background-index",
    "--completion-style=detailed",
    "--header-insertion=never",
    "--clang-tidy",
  }

  if compile_dir then
    table.insert(clangd_cmd, "--compile-commands-dir=" .. compile_dir)
  end

  lspconfig.clangd.setup({
    cmd = clangd_cmd,
    filetypes = { "c", "cpp", "objc", "objcpp", "h", "hpp" },
    capabilities = capabilities,
  })
end

return M

