
local quickfix_expanse = require("nvim-quickfix-expanse")

vim.api.nvim_create_user_command("KeymapsFindByCommand", function(opts)
  quickfix_expanse.search_keymaps(opts.args)
end, { nargs = 1 })
