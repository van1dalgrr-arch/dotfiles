-- Свои автокоманды поверх LazyVim (умолчания: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua)
local group = vim.api.nvim_create_augroup("dotfiles", { clear = true })

-- Автосохранение: вышел из режима вставки, поправил в обычном режиме, ушёл в другое окно — файл записан.
-- Запись запускает форматирование LazyVim: в Go это goimports (сам добавит и уберёт импорты) и gofumpt.
-- Выключить на время: :let g:autosave = v:false
vim.g.autosave = true
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost", "BufLeave" }, {
  group = group,
  nested = true, -- иначе запись не запустит BufWritePre, и форматирование с импортами не сработает
  callback = function(ev)
    local b = vim.bo[ev.buf]
    if not vim.g.autosave or b.buftype ~= "" or not b.modifiable or b.readonly or not b.modified then return end
    local name = vim.api.nvim_buf_get_name(ev.buf)
    if name == "" or vim.fn.filereadable(name) == 0 then return end
    vim.api.nvim_buf_call(ev.buf, function() vim.cmd("silent! write") end)
  end,
})

-- Файлы, которые поменяли снаружи (Claude Code, git, go generate), подхватываются сами,
-- а не только когда окно получает фокус: после паузы в наборе и при переходе между буферами.
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "BufEnter" }, {
  group = group,
  nested = true, -- чтобы после перечитывания сработали подсветка и LSP
  callback = function()
    if vim.fn.mode() ~= "c" and vim.bo.buftype == "" then vim.cmd("silent! checktime") end
  end,
})

-- База проекта для dadbod (пробел D) — как у команды db: из .env или по имени папки
require("dotfiles.system").project_db()
vim.api.nvim_create_autocmd("DirChanged", { group = group, callback = function() require("dotfiles.system").project_db() end })

-- .http — Postman в файле (lua/dotfiles/http.lua): enter на запросе — отправить
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "http",
  callback = function(ev)
    local http = require("dotfiles.http")
    local function map(lhs, fn, desc) vim.keymap.set("n", lhs, fn, { buffer = ev.buf, desc = desc }) end
    map("<cr>", http.send, "HTTP: отправить запрос под курсором")
    map("<leader>Rs", http.send, "HTTP: отправить")
    map("<leader>Rr", http.replay, "HTTP: повторить последний")
    map("<leader>Rc", http.copy_curl, "HTTP: скопировать как curl")
    map("<leader>Rn", function() http.jump(1) end, "HTTP: следующий запрос")
    map("<leader>Rp", function() http.jump(-1) end, "HTTP: предыдущий запрос")
  end,
})
