
local quickfix_expanse = require("nvim-quickfix-expanse")
local all_modes = {"n", "v", "x", "s", "o", "i", "l", "c", "t" }

vim.api.nvim_create_user_command("KeymapsFindByCommand", function(opts)
  quickfix_expanse.find_keymaps_by_command(opts.args, all_modes)
end, { nargs = 1 })

vim.api.nvim_create_user_command("KeymapsFindByDescription", function(opts)
  quickfix_expanse.find_keymaps_by_description(opts.args, all_modes)
end, { nargs = "*" })
