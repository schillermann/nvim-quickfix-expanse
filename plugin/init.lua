local quickfix_expanse = require("nvim-quickfix-expanse")
local all_modes = { "n", "v", "x", "s", "o", "i", "l", "c", "t" }

function is_not_in_list(value, list)
  for _, v in ipairs(list) do
    if v == value then
      return false
    end
  end
  return true
end

vim.api.nvim_create_user_command("KeymapsFindByCommand", function(opts)
  local args = vim.split(opts.args, " ")

  if #args == 1 then
    quickfix_expanse.find_keymaps_by_command(opts.args, all_modes)
    return
  end

  if #args > 1 and is_not_in_list(args[1], all_modes) then
    print("Invalid mode")
    return
  end

  quickfix_expanse.find_keymaps_by_command(args[2], { args[1] })
end, { nargs = "+" })

vim.api.nvim_create_user_command("KeymapsFindByDescription", function(opts)
  local mode, description = string.match(opts.args, "^(%S+)%s*(.*)")

  if is_not_in_list(mode, all_modes) then
    quickfix_expanse.find_keymaps_by_description(opts.args, all_modes)
    return
  end

  quickfix_expanse.find_keymaps_by_description(description, { mode })
end, { nargs = "*" })

vim.api.nvim_create_user_command("FindFiles", function(opts)
  vim.cmd("vimgrep '\\%^' " .. opts.args)
  vim.cmd("copen")
end, { nargs = 1 })
