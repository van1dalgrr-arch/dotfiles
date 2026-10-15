-- Вид и навигация как в IDE: хлебные крошки, ошибки справа от кода, мультикурсоры.
-- Sticky-заголовок функции, окно Structure и переименование с превью — extras в lazyvim.json.
return {
  -- Хлебные крошки сверху: папка › файл › Тип › метод. Клик или пробел ; — выбрать соседний символ
  {
    "Bekaboo/dropbar.nvim",
    event = "LazyFile",
    opts = {},
    keys = {
      { "<leader>;", function() require("dropbar.api").pick() end, desc = "Хлебные крошки: перейти" },
    },
  },
  -- крошки теперь сверху — в статусной строке они не нужны
  { "nvim-lualine/lualine.nvim", optional = true, init = function() vim.g.trouble_lualine = false end },

  -- Ошибки как Error Lens: аккуратная плашка справа от строки, длинное сообщение — в несколько строк.
  -- В режиме вставки текст прячется (не мельтешит при наборе) — значки слева и подчёркивание остаются; esc — снова видно
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,
    opts = {
      preset = "modern",
      options = {
        show_source = { enabled = false }, -- иначе к сообщениям gopls приписывается «[default]»
        multilines = { enabled = true, always_show = false },
        show_all_diags_on_cursorline = true,
        break_line = { enabled = true, after = 60 },
      },
    },
  },
  -- встроенный текст ошибок выключен: его рисует tiny-inline-diagnostic
  { "neovim/nvim-lspconfig", opts = { diagnostics = { virtual_text = false } } },

  -- Мультикурсоры, как Alt+J / Ctrl+G в GoLand.
  -- ctrl-n — курсор на следующем таком же слове, пробел m — меню, alt+клик — поставить/убрать курсор.
  -- Пока курсоры есть: ←/→ — переключаться, пробел x — убрать текущий, esc — убрать все.
  {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    keys = {
      { "<c-n>", function() require("multicursor-nvim").matchAddCursor(1) end, mode = { "n", "x" }, desc = "Курсор на следующем совпадении" },
      { "<leader>m", "", desc = "+мультикурсор", mode = { "n", "x" } },
      { "<leader>mn", function() require("multicursor-nvim").matchAddCursor(1) end, mode = { "n", "x" }, desc = "Следующее совпадение" },
      { "<leader>mN", function() require("multicursor-nvim").matchAddCursor(-1) end, mode = { "n", "x" }, desc = "Предыдущее совпадение" },
      { "<leader>ms", function() require("multicursor-nvim").matchSkipCursor(1) end, mode = { "n", "x" }, desc = "Пропустить совпадение" },
      { "<leader>ma", function() require("multicursor-nvim").matchAllAddCursors() end, mode = { "n", "x" }, desc = "На всех совпадениях" },
      { "<leader>mj", function() require("multicursor-nvim").lineAddCursor(1) end, mode = { "n", "x" }, desc = "Курсор строкой ниже" },
      { "<leader>mk", function() require("multicursor-nvim").lineAddCursor(-1) end, mode = { "n", "x" }, desc = "Курсор строкой выше" },
      { "<leader>ml", function() require("multicursor-nvim").alignCursors() end, desc = "Выровнять курсоры в столбец" },
      { "<leader>mx", function() require("multicursor-nvim").restoreCursors() end, desc = "Вернуть убранные курсоры" },
      { "<M-leftmouse>", function() require("multicursor-nvim").handleMouse() end, desc = "Курсор по клику" },
      { "<M-leftdrag>", function() require("multicursor-nvim").handleMouseDrag() end },
      { "<M-leftrelease>", function() require("multicursor-nvim").handleMouseRelease() end },
    },
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      -- клавиши, которые работают, только пока на экране несколько курсоров
      mc.addKeymapLayer(function(set)
        set({ "n", "x" }, "<left>", mc.prevCursor)
        set({ "n", "x" }, "<right>", mc.nextCursor)
        set({ "n", "x" }, "<leader>x", mc.deleteCursor)
        set("n", "<esc>", function()
          if not mc.cursorsEnabled() then mc.enableCursors() else mc.clearCursors() end
        end)
      end)
    end,
  },
}
