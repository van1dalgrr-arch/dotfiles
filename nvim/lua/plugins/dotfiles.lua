-- Своё поверх LazyVim: внешний вид. Всё остальное — из коробки: https://lazyvim.org
return {
  -- Тема по умолчанию — как была: tokyonight night, прозрачная, в тон терминалу.
  -- Сверху: стеклянные всплывашки и боковые панели (сквозь них видно размытие Ghostty), тихие подсказки типов,
  -- тонкие разделители, заметный номер текущей строки.
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      styles = { sidebars = "transparent", floats = "transparent", keywords = { italic = true } },
      on_highlights = function(hl, c)
        hl.FloatBorder = { fg = c.blue7 }
        hl.FloatTitle = { fg = c.magenta, bold = true }
        hl.WinSeparator = { fg = c.bg_highlight }
        hl.CursorLineNr = { fg = c.orange, bold = true }
        hl.LspInlayHint = { fg = c.dark3, italic = true }
        hl.LspCodeLens = { fg = c.dark3, italic = true }
        hl.TreesitterContext = { bg = c.bg_highlight }
        hl.TreesitterContextBottom = { sp = c.fg_gutter, underline = true }
        hl.Goplements = { fg = c.purple, italic = true }
        hl.DotfilesRunMain = { fg = c.green }
        hl.DotfilesRunTest = { fg = c.teal }
        hl.SnacksDashboardHeader = { fg = c.magenta }
        hl.SnacksDashboardKey = { fg = c.orange, bold = true }
      end,
    },
  },
  -- при старте — тема, выбранная в alt-s (lua/dotfiles/themes.lua), иначе tokyonight
  { "LazyVim/LazyVim", opts = { colorscheme = function() require("dotfiles.themes").load() end } },

  -- Другие темы — alt-s: список с предпросмотром на всём редакторе, enter — запомнить.
  -- Грузятся, только когда выбраны (список видит и незагруженные).
  -- rose-pine — в цветах терминала: палитра из themes/<тема>.sh, светлая — Dev Day (lua/dotfiles/theme.lua)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = function() return require("dotfiles.theme").opts() end,
  },
  { "rebelot/kanagawa.nvim", lazy = true, opts = { transparent = true, theme = "wave" } }, -- kanagawa, kanagawa-dragon
  { "EdenEast/nightfox.nvim", lazy = true, opts = { options = { transparent = true } } }, -- carbonfox, nightfox, duskfox…
  { "scottmckendry/cyberdream.nvim", lazy = true, opts = { transparent = true, italic_comments = true } },
  { "datsfilipe/vesper.nvim", lazy = true, opts = { transparent = true } },
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    init = function()
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_transparent_background = 1
    end,
  },
  -- catppuccin уже есть в LazyVim (catppuccin-mocha, -macchiato…)

  -- Вкладки буферов: тонкие, без крестиков (закрыть — пробел b d)
  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      opts.options = vim.tbl_extend("force", opts.options or {}, {
        separator_style = "thin",
        indicator = { style = "underline" },
        show_buffer_close_icons = false,
        show_close_icon = false,
      })
    end,
  },

  -- Статусная строка «пузырями»: режим, ветка, файл — слева; LSP, позиция, время — справа
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      opts.options.section_separators = { left = "", right = "" }
      opts.options.component_separators = { left = "", right = "" }
      opts.sections.lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } }
      -- какие языковые серверы подключены к файлу (как значок gopls в углу GoLand)
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients({ bufnr = 0 }))
          return #names > 0 and (" " .. table.concat(names, " ")) or ""
        end,
        color = function() return { fg = Snacks.util.color("Comment") } end,
      })
      opts.sections.lualine_z = { { function() return " " .. os.date("%H:%M") end, separator = { right = "" }, left_padding = 2 } }
    end,
  },

  -- Стартовый экран: клавиши слева, недавние файлы, проекты и git справа
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = [[
██████╗ ███████╗██╗   ██╗
██╔══██╗██╔════╝██║   ██║
██║  ██║█████╗  ██║   ██║
██║  ██║██╔══╝  ╚██╗ ██╔╝
██████╔╝███████╗ ╚████╔╝ 
╚═════╝ ╚══════╝  ╚═══╝  
neovim · go · без лицензий]],
          keys = {
            { icon = " ", key = "f", desc = "Найти файл", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "r", desc = "Недавние файлы", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "g", desc = "Поиск по проекту", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "s", desc = "Вернуть прошлую сессию", section = "session" },
            { icon = "󰊢 ", key = "G", desc = "lazygit", action = function() Snacks.lazygit() end },
            { icon = "󰚩 ", key = "a", desc = "Claude Code", action = "<cmd>ClaudeCode<cr>" },
            { icon = " ", key = "e", desc = "Эндпоинты API", action = function() require("dotfiles.endpoints").pick() end },
            { icon = "󰋖 ", key = "h", desc = "Шпаргалка", action = function() require("dotfiles.cheatsheet").open() end },
            { icon = "󰒲 ", key = "l", desc = "Плагины", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Выйти", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          { pane = 2, padding = 8 },
          { pane = 2, icon = " ", title = "Недавние файлы", section = "recent_files", cwd = true, indent = 2, padding = 1 },
          { pane = 2, icon = " ", title = "Проекты", section = "projects", indent = 2, padding = 1 },
          -- git status без терминала: в терминальном блоке висела строка «[Process exited 0]»
          function()
            if not Snacks.git.get_root() then return {} end
            local lines = vim.fn.systemlist({ "git", "status", "--short", "--branch" })
            local items = { { pane = 2, icon = " ", title = "Git", padding = 1 } }
            for i, line in ipairs(vim.list_slice(lines, 1, 6)) do
              items[#items + 1] = { pane = 2, text = { { line, hl = i == 1 and "Special" or "Comment" } }, indent = 3 }
            end
            return items
          end,
        },
      },
    },
  },

  -- Подсказка к функции и hover — в рамке, как всплывашки в GoLand
  { "folke/noice.nvim", optional = true, opts = { presets = { lsp_doc_border = true } } },
}
