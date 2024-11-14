local M = {}

local function get_data_dir()
	local config_dir = vim.fn.stdpath("data")
	local plugin_dir = config_dir .. "/goto"

	-- Create directory if it doesn't exist
	if vim.fn.isdirectory(plugin_dir) == 0 then
		vim.fn.mkdir(plugin_dir, "p")
	end

	return plugin_dir
end

local function hash(path)
	return vim.fn.sha256(path)
end

-- Hash the current working directory
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

-- Read JSON from file
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

	-- Use vim.json to decode
	local ok, data = pcall(vim.json.decode, content)
	if not ok then
		vim.notify("Failed to parse JSON: " .. data, vim.log.levels.ERROR)
		return {}
	end

	return data
end

-- Write JSON to file
function M.write_json(file_path, data)
	local file = io.open(file_path, "w")

	if not file then
		vim.notify("Failed to open file for writing: " .. file_path, vim.log.levels.ERROR)
		return false
	end

	-- Use vim.json to encode
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
