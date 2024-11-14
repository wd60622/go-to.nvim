local io = require("go-to.io")
local picker = require("go-to.picker")

local M = {}

M.config = {
	display_only = false,
	confirm_delete = true,
}

local function show_commands(callback)
	local file_path = io.local_file_path()
	local data = io.read_json(file_path)
	if next(data) == nil then
		print("No commands found!")
		return
	end

	local opts = {
		data = data,
		callback = callback,
		display_only = M.config.display_only,
	}
	picker.show_commands(opts)
end

function M.show_commands(opts)
	show_commands(opts.callback)
end

function M.edit_commands()
	local file_path = io.local_file_path()
	vim.cmd("edit " .. file_path)
end

local function trim(str)
	if not str then
		return nil
	end
	return str:gsub("^%s*(.-)%s*$", "%1")
end

function M.add_command(opts)
	local display = opts.display or vim.fn.input("Display: ")
	local command = opts.command or vim.fn.input("Command: ")

	display = trim(display)
	command = trim(command)

	if display == nil then
		return
	end

	local file_path = io.local_file_path()
	local data = io.read_json(file_path)
	data[display] = command
	io.write_json(file_path, data)
end

function M.delete_command()
	show_commands(function(selection)
		local display = selection.value.display

		-- Check if the user wants to delete the command
		if M.config.confirm_delete and vim.fn.input("Delete " .. display .. "? (y/n): ") ~= "y" then
			return
		end

		local file_path = io.local_file_path()
		local data = io.read_json(file_path)
		data[display] = nil
		io.write_json(file_path, data)
		print("Deleted " .. display)
	end)
end

function M.setup(opts)
	M.config = vim.tbl_extend("force", M.config, opts or {})

	vim.api.nvim_create_user_command("ShowCommands", M.show_commands, {})
	vim.api.nvim_create_user_command("EditCommands", M.edit_commands, {})
	vim.api.nvim_create_user_command("AddCommand", M.add_command, {})
	vim.api.nvim_create_user_command("DeleteCommand", M.delete_command, {})
end

return M