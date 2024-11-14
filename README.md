# go-to.nvim

Store your go-to commands and access them with fuzzy search.

![ShowCommands](images/go-to.png)

## Installation

Install with your favorite plugin manager, for example with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "wd60622/go-to.nvim",
    dependencies = { "nvim-telscope/telescope.nvim" },
    opts = {
        display_only = false,
        confirm_delete = true,
        sort_by = "frequency", -- "frequency", "alphabetical", or callable
    },
}
```

## Usage

The plugin provides the following commands:

| Command | Description |
| --- | --- |
| `AddCommand` | Add a new command to the list. |
| `ShowCommands` | Show all commands in the list. |
| `DeleteCommand` | Delete a command from the list. |
| `EditCommands` | Edit the commands in their file format. |

Each set of commands are project specific.

While in command mode, use `<C-s>` to save off the current command to the list.
