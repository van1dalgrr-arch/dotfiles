-- Шпаргалка (docs/nvim.ru.md) в окне поверх кода: render-markdown рисует таблицы, q или esc — закрыть.
local M = {}

function M.open()
  local file = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.stdpath("config")), ":h") .. "/docs/nvim.ru.md"
  Snacks.win({
    file = file,
    width = 0.8,
    height = 0.85,
    border = "rounded",
    title = " Шпаргалка · / — поиск · q — закрыть ",
    title_pos = "center",
    bo = { modifiable = false, filetype = "markdown" },
    wo = { conceallevel = 2, wrap = false, spell = false, number = false, relativenumber = false, signcolumn = "no" },
    keys = { q = "close", ["<esc>"] = "close" },
  })
end

return M
