-- Свои клавиши поверх LazyVim (умолчания: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua)
-- Отладка — на тех же F-клавишах, что в Rune и GoLand (на маке через fn).
local map = vim.keymap.set
local function dap(fn) return function() require("dap")[fn]() end end

map("n", "<F8>", dap("step_over"), { desc = "Debug: шаг (как в GoLand)" })
map("n", "<F7>", dap("step_into"), { desc = "Debug: внутрь" })
map("n", "<S-F8>", dap("step_out"), { desc = "Debug: наружу" })
map("n", "<F9>", dap("continue"), { desc = "Debug: запустить / дальше" })
map("n", "<C-F8>", dap("toggle_breakpoint"), { desc = "Debug: точка останова" })
