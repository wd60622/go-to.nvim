local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

local function alphabetical_sorter(a, b)
	return a.display < b.display
end

local function frequency_sorter(a, b)
	return a.number > b.number
end

local function create_sort(sorter)
	return function(data)
		table.sort(data, sorter)
		return data
	end
end

local sort_options = {
	alphabetical = create_sort(alphabetical_sorter),
	frequency = create_sort(frequency_sorter),
}

local function display_entry_maker(entry, max_width)
	-- Just display the display name
	local displayer = entry_display.create({
		separator = " ", -- Separator between columns
		items = {
			{ width = max_width }, -- Width of first column
		},
	})

	local make_display = function()
		return displayer({
			{ entry.display, "TelescopeResultsIdentifier" }, -- First column (blue)
		})
	end

	return {
		value = entry,
		display = make_display,
		ordinal = entry.display,
	}
end

local function display_command_entry_maker(entry, max_width)
	local displayer = entry_display.create({
		separator = " ", -- Separator between columns
		items = {
			{ width = max_width }, -- Width of first column
			{ remaining = true }, -- Second column takes remaining space
		},
	})

	local make_display = function()
		return displayer({
			{ entry.display, "TelescopeResultsIdentifier" }, -- First column (blue)
			{ entry.command, "TelescopeResultsConstant" }, -- Second column (yellow)
		})
	end

	return {
		value = entry,
		display = make_display,
		ordinal = entry.display .. " " .. entry.command,
	}
end

function M.show_commands(opts)
	local data = opts.data
	local entry_maker
	if opts.display_only then
		entry_maker = display_entry_maker
	else
		entry_maker = display_command_entry_maker
	end
	-- Convert data to format telescope expects
	local commands = {}
	for key, value in pairs(data) do
		table.insert(commands, {
			display = key,
			command = value.command,
			number = value.number,
		})
	end

	local max_width = 0
	for _, command in ipairs(commands) do
		max_width = math.max(max_width, #command.display)
	end
	-- Max 1.25 times the width of "Command"
	max_width = math.floor(1.25 * max_width)

	local sorter = sort_options[opts.sort]
	if sorter then
		commands = sorter(commands)
	end

	-- Create picker
	pickers
		.new({}, {
			prompt_title = "Commands",
			finder = finders.new_table({
				results = commands,
				entry_maker = function(entry)
					return entry_maker(entry, max_width)
				end,
			}),
			sorter = conf.generic_sorter(),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					-- Enter command in command line
					if not selection then
						return
					end
					opts.callback(selection)
				end)
				return true
			end,
		})
		:find()
end

return M
