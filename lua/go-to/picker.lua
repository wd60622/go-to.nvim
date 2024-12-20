local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local M = {}

local function alphabetical_sorter(a, b)
  return string.lower(a.display) < string.lower(b.display)
end

local function frequency_sorter(a, b)
  return a.number > b.number
end

local function recency_sorted(a, b)
  return (a.lastUsed or "") > (b.lastUsed or "")
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
  recency = create_sort(recency_sorted),
}

local function display_entry_maker(entry, max_width)
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = max_width },
    },
  })

  local make_display = function()
    return displayer({
      { entry.display, "TelescopeResultsIdentifier" },
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
    separator = " ",
    items = {
      { width = max_width },
      { remaining = true },
    },
  })

  local make_display = function()
    return displayer({
      { entry.display, "TelescopeResultsIdentifier" },
      { entry.command, "TelescopeResultsConstant" },
    })
  end

  return {
    value = entry,
    display = make_display,
    ordinal = entry.display .. " " .. entry.command,
  }
end

local create_commands = function(data)
  local commands = {}
  for key, value in pairs(data) do
    local row = vim.tbl_extend("force", { display = key }, value)
    table.insert(commands, row)
  end
  return commands
end

function M.show_commands(opts)
  local data = opts.data
  local entry_maker
  if opts.display_only then
    entry_maker = display_entry_maker
  else
    entry_maker = display_command_entry_maker
  end

  local commands = create_commands(data)

  local max_width = 0
  for _, command in ipairs(commands) do
    max_width = math.max(max_width, #command.display)
  end

  max_width = math.floor(1.25 * max_width)

  local sorter
  if type(opts.sort_by) == "function" then
    sorter = create_sort(opts.sort_by)
  else
    sorter = sort_options[opts.sort_by]
  end
  if sorter then
    commands = sorter(commands)
  end

  pickers
    .new({}, {
      results_title = "Go-To Commands",
      finder = finders.new_table({
        results = commands,
        entry_maker = function(entry)
          return entry_maker(entry, max_width)
        end,
      }),
      sorter = conf.generic_sorter(),
      attach_mappings = function(prompt_bufnr, map)
        map("i", "<CR>", nil)
        map("n", "<CR>", nil)

        map("i", "<CR>", function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          if not selection then
            return
          end
          opts.callback(selection)
        end)

        for key, value in pairs(opts.mappings) do
          map("i", key, function()
            if value.close then
              actions.close(prompt_bufnr)
            end
            local selection = action_state.get_selected_entry()
            value.action(selection)
          end)
        end

        return true
      end,
    })
    :find()
end

return M
