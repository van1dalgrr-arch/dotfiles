-- Удобно писать и ходить по коду без мыши, не зная сотни команд.
-- Летающий курсор — extra ui.smear-cursor в lazyvim.json.
return {
  -- Ходить без мыши: смотришь, куда надо, — жмёшь букву метки.
  --   enter      — метка в начале каждой строки на экране → буква → курсор там
  --   s + буквы  — метки на совпадениях → буква (как было)
  -- Метки работают и в русской раскладке: «ф» = a, «ы» = s…
  {
    "folke/flash.nvim",
    optional = true,
    keys = {
      {
        "<cr>",
        function()
          -- в списках (quickfix, деревья) enter остаётся своим: открыть, перейти
          if vim.bo.buftype ~= "" then return vim.cmd("normal! \r") end
          require("flash").jump({
            search = { mode = "search", max_length = 0, multi_window = false },
            label = { after = { 0, 0 }, uppercase = true },
            pattern = [[^\s*\zs\S]], -- начало текста строки, а не отступ
          })
        end,
        desc = "Прыжок на строку (метки)",
      },
    },
    config = function(_, opts)
      require("flash").setup(opts)
      -- flash читает буквы мимо langmap: переводим русские буквы в латинские сами
      local ru = {}
      for from, to in vim.o.langmap:gmatch("([^,;]+);([^,]+)") do
        local f, t = vim.fn.split(from, [[\zs]]), vim.fn.split(to, [[\zs]])
        for i, ch in ipairs(f) do ru[ch] = t[i] end
      end
      local util = require("flash.util")
      local get_char = util.get_char
      util.get_char = function()
        local ch = get_char()
        return ch and ru[ch] or ch
      end
    end,
  },

  -- Подсказка аргументов, пока печатаешь вызов: сигнатура над строкой, текущий аргумент выделен
  {
    "saghen/blink.cmp",
    optional = true,
    opts = { signature = { enabled = true, window = { border = "rounded" } } },
  },
}
