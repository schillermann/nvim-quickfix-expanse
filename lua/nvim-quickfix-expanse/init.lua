local Module = {}

local function split_string(input)
    local result = {}
    for i = 1, #input do
        table.insert(result, string.lower(string.sub(input, i, i)))
    end
    return result
end

local function escape_pattern(text)
    return string.gsub(text, "([^%w])", "%%%1")
end

local function get_keymap_with_space_char(keymap)
  return string.gsub(keymap, "<space>", " ")
end

local function get_keymap_with_space_label(keymap)
  return string.gsub(keymap, " ", "<space>")
end

local function get_search_pattern(input)
  local search_pattern = ".*"
  local characters = split_string(get_keymap_with_space_char(input))
  for _, character in ipairs(characters) do
    search_pattern = search_pattern .. escape_pattern(character) .. ".*"
  end
  return search_pattern
end

local function extractFilePathAndLineNumber(str)
    local filePath, lineNumber = string.match(str, "([%w%p]+/[%w%p]+%.%w+):(%d+)")
    if not filePath then
        filePath, lineNumber = string.match(str, "from ([%w%p]+/[%w%p]+%.%w+) line (%d+)")
    end
    if not filePath then
      return "", 0
    end
    return filePath, lineNumber
end

local function expand_tilde(path)
    if string.sub(path, 1, 1) == "~" then
        local home = os.getenv("HOME")
        if home then
            return home .. string.sub(path, 2)
        end
    end
    return path
end

local function get_without_nil(input)
  if input == nil then
    return ""
  end
  return input
end

local function filter_keymaps(keymaps, search_pattern, mode)
  local results = {}

  for _, keymap in ipairs(keymaps) do
    if string.match(string.lower(keymap.lhs), search_pattern) then
      local mapOutput = vim.fn.execute("verbose " .. mode .. "map " .. get_keymap_with_space_label(keymap.lhs))
      local filePath, lineNumber = extractFilePathAndLineNumber(mapOutput)

      table.insert(results, {
        filename = expand_tilde(filePath),
        lnum = lineNumber or keymap.lnum,
        col = 1,
        text = string.format("%s | %s | %s", keymap.mode, get_keymap_with_space_label(keymap.lhs), get_without_nil(keymap.desc))
      })
    end
  end

  return results
end

local function add_keymaps_from_buffer_to_quickfix_list(search_pattern, modes)
  for _, mode in ipairs(modes) do
    local bufnr = vim.api.nvim_get_current_buf()
    local keymaps = vim.api.nvim_buf_get_keymap(bufnr, mode)
    vim.fn.setqflist(filter_keymaps(keymaps, search_pattern, mode), "a")
  end
end

local function add_keymaps_from_global_to_quickfix_list(search_pattern, modes)
  for _, mode in ipairs(modes) do
    local keymaps = vim.api.nvim_get_keymap(mode)
    vim.fn.setqflist(filter_keymaps(keymaps, search_pattern, mode), "a")
  end
end

function Module.search_keymaps(lhs)
  local all_modes = {"n", "v", "x", "s", "o", "i", "l", "c", "t" }
  local search_pattern = get_search_pattern(lhs)

  add_keymaps_from_buffer_to_quickfix_list(search_pattern, all_modes)
  add_keymaps_from_global_to_quickfix_list(search_pattern, all_modes)
  vim.cmd('copen')
end

return Module
