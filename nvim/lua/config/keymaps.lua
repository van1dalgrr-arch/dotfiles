-- Свои клавиши поверх LazyVim (умолчания: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua)
-- Отладка — на тех же F-клавишах, что в Rune и GoLand (на маке через fn).
local map = vim.keymap.set
local function dap(fn) return function() require("dap")[fn]() end end

map("n", "<F8>", dap("step_over"), { desc = "Debug: шаг (как в GoLand)" })
map("n", "<F7>", dap("step_into"), { desc = "Debug: внутрь" })
map("n", "<S-F8>", dap("step_out"), { desc = "Debug: наружу" })
map("n", "<F9>", dap("continue"), { desc = "Debug: запустить / дальше" })
map("n", "<C-F8>", dap("toggle_breakpoint"), { desc = "Debug: точка останова" })

-- Переместить выделенные строки: alt-j/alt-k из LazyVim забирает AeroSpace (весь слой alt — его).
-- V, выделить, J/K — и строки едут вниз/вверх, отступы поправляются сами.
map("x", "J", ":m '>+1<cr>gv=gv", { desc = "Строки вниз", silent = true })
map("x", "K", ":m '<-2<cr>gv=gv", { desc = "Строки вверх", silent = true })

-- Эндпоинты Gin, как в GoLand: все маршруты с полным путём, enter — к хендлеру, ctrl-y — curl
map("n", "<leader>re", function() require("dotfiles.endpoints").pick() end, { desc = "Эндпоинты (Gin)" })
map("n", "<leader>rh", function() require("dotfiles.endpoints").http_file() end, { desc = "api.http — Postman в файле" })

-- Система: контейнеры, dot (lua/dotfiles/system.lua)
local sys = require("dotfiles.system")
map("n", "<leader>rc", sys.containers, { desc = "Контейнеры (orbstack)" })
map("n", "<leader>rp", sys.dot("project doctor ."), { desc = "dot project doctor" })
map("n", "<leader>rw", sys.dot("work"), { desc = "dot work — что поднято" })
map("n", "<leader>rb", sys.dot("backup"), { desc = "dot backup" })

-- Одно нажатие вместо пробел+буквы: alt + буква (эти alt-буквы AeroSpace не забирает)
map({ "n", "t" }, "<M-o>", sys.containers, { desc = "orbstack — контейнеры (alt-o ещё раз — закрыть)" })
map("n", "<M-g>", function() Snacks.lazygit({ cwd = LazyVim.root.git() }) end, { desc = "lazygit" })
map("n", "<M-p>", function() require("dotfiles.endpoints").http_file() end, { desc = "Postman: api.http проекта" })
map("n", "<M-a>", function() require("dotfiles.endpoints").pick() end, { desc = "Эндпоинты API" })
map("n", "<M-d>", "<cmd>DBUIToggle<cr>", { desc = "База данных (alt-d ещё раз — закрыть)" })
map("n", "<M-t>", "<cmd>OverseerRun<cr>", { desc = "Задачи" })
-- те же клавиши в русской раскладке: alt-щ = alt-o и т.д. (langmap на сочетания с alt не действует)
for ru, en in pairs({ ["щ"] = "o", ["п"] = "g", ["з"] = "p", ["ф"] = "a", ["в"] = "d", ["е"] = "t" }) do
  local m = vim.fn.maparg("<M-" .. en .. ">", "n", false, true)
  if m.callback or m.rhs then map(en == "o" and { "n", "t" } or "n", "<M-" .. ru .. ">", m.callback or m.rhs, { desc = m.desc }) end
end
