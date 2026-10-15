-- Совет дня на стартовом экране: случайная строка из шпаргалки (docs/nvim.ru.md) — каждый запуск новая.
-- Шпаргалка дописывается — советы появляются сами.
local M = {}

local cheatsheet = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.stdpath("config")), ":h") .. "/docs/nvim.ru.md"

local function clean(s)
  return vim.trim((s:gsub("\\|", "|"):gsub("`", ""):gsub("%*%*", "")))
end

-- строки таблиц: «| клавиши | что | пример |» и «| GoLand | клавиши nvim | что |»
function M.all()
  local tips = {}
  local f = io.open(cheatsheet)
  if not f then return tips end
  for line in f:lines() do
    local cells = {}
    for cell in line:gsub("\\|", "\1"):gmatch("|([^|]*)") do cells[#cells + 1] = cell:gsub("\1", "\\|") end
    if #cells >= 3 and not line:match("^|%-") then
      local c1, c2, c3 = cells[1], cells[2], cells[3] or ""
      if c1:find("`") then
        local desc = clean(c2)
        if clean(c3) ~= "" then desc = desc .. " — " .. clean(c3) end
        tips[#tips + 1] = { keys = clean(c1), desc = desc }
      elseif c2:find("`") then -- таблица GoLand → nvim
        tips[#tips + 1] = { keys = clean(c2), desc = clean(c3) .. "  (в GoLand: " .. clean(c1) .. ")" }
      end
    end
  end
  f:close()
  return tips
end

function M.random()
  local tips = M.all()
  if #tips == 0 then return nil end
  return tips[math.floor(vim.uv.hrtime() / 1e3) % #tips + 1]
end

-- секция для snacks dashboard
function M.section()
  local tip = M.random()
  if not tip then return {} end
  local desc = vim.fn.strcharlen(tip.desc) > 90 and (vim.fn.strcharpart(tip.desc, 0, 88) .. "…") or tip.desc
  return {
    align = "center",
    padding = 1,
    text = {
      { "󰌵 совет  ", hl = "Comment" },
      { tip.keys, hl = "Special" },
      { "  " .. desc, hl = "SnacksDashboardDesc" },
    },
  }
end

return M
