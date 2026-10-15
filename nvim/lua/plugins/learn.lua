-- Учиться vim на ходу: подсказки движений прямо в тексте и мягкий тренер привычек.
-- Выучил — выключи: пробел u P (метки) и пробел u H (тренер).
return {
  -- Серые метки над строкой: куда прыгнут w, b, e, ^, $, { и }. Видно, какое движение короче hjkl.
  {
    "tris203/precognition.nvim",
    event = "VeryLazy",
    opts = {
      startVisible = true,
      showBlankVirtLine = false, -- на пустой строке подсказывать нечего — без лишней строки
      highlightColor = { link = "Comment" },
      -- только главные движения: w b e ^ $ % — без W/B/E/0 и без меток f/t, иначе строка-подсказка как каша
      targetedMotionHints = { enabled = false },
      hints = {
        Caret = { text = "^", prio = 2 },
        Dollar = { text = "$", prio = 1 },
        MatchingPair = { text = "%", prio = 5 },
        w = { text = "w", prio = 10 },
        b = { text = "b", prio = 9 },
        e = { text = "e", prio = 8 },
        Zero = { text = "0", prio = 0 },
        W = { text = "W", prio = 0 },
        B = { text = "B", prio = 0 },
        E = { text = "E", prio = 0 },
      },
    },
    config = function(_, opts)
      local p = require("precognition")
      p.setup(opts)
      Snacks.toggle({
        name = "Подсказки движений",
        get = function() return p.is_visible and p.is_visible() or vim.g.precognition_on ~= false end,
        set = function(on)
          vim.g.precognition_on = on
          if on then p.show() else p.hide() end
        end,
      }):map("<leader>uP")
    end,
  },

  -- Тренер: заметит jjjjj или повтор одного и того же и подскажет короче (5j, }, ciw…).
  -- Только подсказывает — ничего не запрещает, стрелки и мышь работают.
  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      restriction_mode = "hint",
      disabled_keys = {}, -- стрелки нужны мультикурсорам и терминалу
      disable_mouse = false,
    },
    keys = {
      { "<leader>uH", "<cmd>Hardtime toggle<cr>", desc = "Тренер vim (hardtime) вкл/выкл" },
    },
  },
}
