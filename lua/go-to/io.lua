local M = {}

function M.data_dir_status()
  local config_dir = vim.fn.stdpath("data")
  local plugin_dir = config_dir .. "/go-to"

  return vim.fn.isdirectory(plugin_dir) == 1, plugin_dir
end

local function get_data_dir()
  local exists, plugin_dir = M.data_dir_status()
  if not exists then
    vim.fn.mkdir(plugin_dir, "p")
  end

  return plugin_dir
end

local function hash(path)
  return vim.fn.sha256(path)
end

function M.hash_cwd()
  local cwd = vim.loop.cwd()
  local full_hash = hash(cwd)
  return string.sub(full_hash, 1, 6)
end

function M.get_file_path(filename)
  return get_data_dir() .. "/" .. filename
end

function M.local_file_path()
  return get_data_dir() .. "/" .. M.hash_cwd() .. ".json"
end

function M.read_json(file_path)
  local file = io.open(file_path, "r")

  if not file then
    return {}
  end

  local content = file:read("*a")
  file:close()

  if content == "" then
    return {}
  end

  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("Failed to parse JSON: " .. data, vim.log.levels.ERROR)
    return {}
  end

  return data
end

function M.write_json(file_path, data)
  local file = io.open(file_path, "w")

  if not file then
    vim.notify(
      "Failed to open file for writing: " .. file_path,
      vim.log.levels.ERROR
    )
    return false
  end

  local ok, encoded = pcall(vim.json.encode, data)
  if not ok then
    vim.notify("Failed to encode JSON: " .. encoded, vim.log.levels.ERROR)
    return false
  end

  file:write(encoded)
  file:close()
  return true
end

return M
