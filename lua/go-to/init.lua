local io = require("go-to.io")
local picker = require("go-to.picker")

local M = {}

M.config = {
  display_only = false,
  confirm_delete = true,
  sort_by = "frequency",
  mappings = {
    ["<C-e>"] = {
      action = function(selection)
        local cmd = ":" .. selection.value.command .. " "
        vim.fn.feedkeys(
          vim.api.nvim_replace_termcodes(cmd, true, true, true),
          "n"
        )
      end,
      close = true,
    },
    ["<C-d>"] = {
      action = function(selection)
        vim.notify("Trying to delete " .. selection.value.display)
      end,
      close = false,
    },
  },
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
    sort_by = M.config.sort_by,
    mappings = M.config.mappings,
  }
  picker.show_commands(opts)
end

function M.show_commands(opts)
  opts.callback = function(selection)
    local file_path = io.local_file_path()
    local data = io.read_json(file_path)
    data[selection.value.display].number = data[selection.value.display].number
      + 1
    io.write_json(file_path, data)

    vim.cmd(":" .. selection.value.command)
  end
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
  local command = opts.command or vim.fn.input("Enter Command: ")
  local display = opts.display or vim.fn.input("Enter Display: ")

  if
    not display
    or display == nil
    or display == ""
    or not command
    or display == nil
    or command == ""
  then
    print("Display and command are required!")
    return
  end

  display = trim(display)
  command = trim(command)

  local file_path = io.local_file_path()
  local data = io.read_json(file_path)
  data[display] = { command = command, number = 0 }
  io.write_json(file_path, data)
end

function M.delete_command()
  show_commands(function(selection)
    local display = selection.value.display

    if
      M.config.confirm_delete
      and vim.fn.input("Delete " .. display .. "? (y/n): ") ~= "y"
    then
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
  vim.api.nvim_create_user_command("AddCommand", M.add_command, { nargs = "*" })
  vim.api.nvim_create_user_command("DeleteCommand", M.delete_command, {})

  vim.keymap.set("c", "<C-s>", function()
    local cmd_type = vim.fn.getcmdtype()
    if cmd_type ~= ":" then
      return
    end

    M.add_command({ command = vim.fn.getcmdline() })
  end)
end

return M
