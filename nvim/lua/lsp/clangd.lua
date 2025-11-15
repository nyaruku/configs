local M = {}

-- Function to recursively search for compile_commands.json
local function find_compile_commands(start_dir)
  local uv = vim.loop
  local function exists(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == "file"
  end

  local function is_dir(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == "directory"
  end

  local dir = start_dir
  while dir and dir ~= "/" do
    -- Search recursively under this dir
    local function search_recursive(path, depth)
      if depth > 3 then return nil end -- avoid infinite crawl
      local handle = uv.fs_scandir(path)
      if not handle then return nil end
      while true do
        local name, type = uv.fs_scandir_next(handle)
        if not name then break end
        local fullpath = path .. "/" .. name
        if name == "compile_commands.json" and type == "file" then
          return path
        elseif type == "directory" then
          local sub = search_recursive(fullpath, depth + 1)
          if sub then return sub end
        end
      end
      return nil
    end

    local found = search_recursive(dir, 0)
    if found then return found end

    -- Go up one directory level
    dir = dir:match("(.+)/[^/]+$")
  end
  return nil
end

-- Detect C/C++ standard from compile_commands or fallback
local function detect_cpp_standard()
  local compile_json_path = find_compile_commands(vim.fn.getcwd())
  if not compile_json_path then return "c++20" end

  local file = io.open(compile_json_path .. "/compile_commands.json", "r")
  if not file then return "c++20" end

  local content = file:read("*a")
  file:close()

  local std = content:match("%-%-std=([%w%+]+)")
  return std or "c++20"
end

local function detect_c_standard()
  local compile_json_path = find_compile_commands(vim.fn.getcwd())
  if not compile_json_path then return "c17" end

  local file = io.open(compile_json_path .. "/compile_commands.json", "r")
  if not file then return "c17" end

  local content = file:read("*a")
  file:close()

  local std = content:match("%-%-std=([%w%+]+)")
  if std and std:match("^c%d") then
    return std
  end
  return "c17"
end

function M.setup()
  local lspconfig = require("lspconfig")
  local capabilities = require("cmp_nvim_lsp").default_capabilities()

  local compile_dir = find_compile_commands(vim.fn.getcwd())
  local cpp_std = detect_cpp_standard()
  local c_std = detect_c_standard()

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
    init_options = {
      fallbackFlags = {
        "-std=" .. cpp_std,
        "-Wall",
        "-Wextra",
        "-Wpedantic",
      },
    },
    capabilities = capabilities,
  })
end

return M

