-- Свои опции поверх LazyVim (умолчания: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua)

-- vim-команды работают и в русской раскладке: «о» = j, «л» = k, «вв» = dd, «Ж» = :, «ц» = w…
-- Переключать язык ради hjkl и :w не нужно; в режиме вставки буквы печатаются как есть.
-- (строчные написаны явно: string.lower в Lua понимает только латиницу)
local RU, ru = [[ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ]], [[фисвуапршолдьтщзйкыегмцчня]]
local EN, en = [[ABCDEFGHIJKLMNOPQRSTUVWXYZ]], [[abcdefghijklmnopqrstuvwxyz]]
vim.opt.langmap = RU .. ";" .. EN .. "," .. ru .. ";" .. en
  .. [[,Х{,х[,Ъ},ъ],Ж:,ж\;,Э",э',Б<,б\,,Ю>,ю.,ё`,Ё~]]

-- как в старом init.lua: больше строк вокруг курсора
vim.opt.scrolloff = 8

-- цвета для ▶, «реализует:», мультикурсоров в любой теме; rose-pine следит за темой dotfiles
require("dotfiles.theme").watch()

-- все всплывающие окна (hover, подсказки, ошибки) — в скруглённой рамке
vim.o.winborder = "rounded"
