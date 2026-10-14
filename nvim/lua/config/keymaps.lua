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
