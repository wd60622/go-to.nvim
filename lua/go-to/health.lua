local health = vim.health or require("health")
local start = health.start
local ok = health.ok
local info = health.info
local error = health.error

local io = require("go-to.io")

local function lualib_installed(lib_name)
  local res, _ = pcall(require, lib_name)
  return res
end

local dependencies = {
  { name = "telescope", required = true },
  { name = "notify", required = false },
}

local M = {}

M.check = function()
  start("Checking for installations")
  for _, plugin in ipairs(dependencies) do
    if lualib_installed(plugin.name) then
      ok(plugin.name .. " installed")
    elseif not plugin.required then
      info(plugin.name .. " is not installed")
    else
    end
  end

  local exists, plugin_dir = io.data_dir_status()
  if not exists then
    info(
      "Storage location "
        .. plugin_dir
        .. " doesn't exist yet. Will create when creating a command."
    )
  else
    ok("Storage location " .. plugin_dir .. " already exists.")
  end

  ok("The go-to.nvim plugin is good to go!")
end

return M
