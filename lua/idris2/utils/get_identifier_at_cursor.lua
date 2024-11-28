-- Function to get the identifier at cursor
-- Identifier is a string, [A-Za-z0-9_.]
-- if cursor is at any character of `M.Nothing` inside of `leftSide _ = M.Nothing` it will return `{ module = "M", identifier = "Nothing" }`
-- if cursor is at any character of `Nothing` inside of `leftSide _ = Nothing` it will return `{ identifier = "Nothing" }`
-- if cursor is at any character of `A.M.Nothing` inside of `leftSide _ = A.M.Nothing` it will return `{ module = "A.M", identifier = "Nothing" }`
-- if cursor is at any character of `A.M.Nothing.something` inside of `leftSide _ = A.M.Nothing.something` it will return `{ module = "A.M.Nothing", identifier = "something" }`
-- if cursor is at any character of `JsonDecodeError` inside of `decodeWorkerInput :: J.Json -> Either JsonDecodeError WorkerInput_Implementation` it will return `{ identifier = "JsonDecodeError" }`
--
-- to test :lua =require("idris2.utils.get_identifier_at_cursor")()


local function get_identifier_at_cursor()
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_buf_get_lines(0, cursor_row - 1, cursor_row, false)[1]

  -- Find the start and end of the identifier
  local start_col = cursor_col + 1 -- +1 because Lua strings are 1-indexed
  while start_col > 1 and line:sub(start_col - 1, start_col - 1):match('[A-Za-z0-9_.]') do
    start_col = start_col - 1
  end

  local end_col = start_col
  while end_col <= #line and line:sub(end_col, end_col):match('[A-Za-z0-9_.]') do
    end_col = end_col + 1
  end
  end_col = end_col - 1

  local full_identifier = line:sub(start_col, end_col)

  -- Split the identifier into module and name parts
  local parts = {}
  for part in full_identifier:gmatch('[^.]+') do
    table.insert(parts, part)
  end

  local result = {}
  if #parts > 1 then
    result.identifier = parts[#parts]
    result.module = table.concat(parts, ".", 1, #parts - 1)
  else
    result.identifier = parts[1]
  end

  return result
end

return get_identifier_at_cursor
