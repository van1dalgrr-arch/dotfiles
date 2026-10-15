-- Go как в GoLand — то, чего нет в LazyVim из коробки. Все клавиши — в шпаргалке (пробел h).
-- Группа «пробел G» — генерация кода, «пробел c» — рефакторинги, «g p» — посмотреть, не уходя из файла.
local function code_action(kind)
  return function() vim.lsp.buf.code_action({ context = { only = { kind }, diagnostics = {} } }) end
end

local function prompt(text, cmd)
  return function()
    vim.ui.input({ prompt = text }, function(arg)
      if arg and arg ~= "" then vim.cmd(cmd .. " " .. arg) end
    end)
  end
end

return {
  -- gopls и общие клавиши LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- надписи над кодом: в go.mod — «обновить зависимость / tidy / govulncheck», над //go:generate — запуск
      codelens = { enabled = true },
      servers = {
        gopls = {
          settings = {
            gopls = {
              codelenses = { test = false }, -- тесты запускает ▶ слева (пробел r x), а не надпись над функцией
              analyses = { shadow = true }, -- err := … внутри if затеняет внешний err — как инспекция GoLand
              hints = { parameterNames = false }, -- «a...:» в fmt.Println( — шум; типы переменных и полей остаются
            },
          },
        },
        ["*"] = {
          keys = {
            -- Alt+Enter GoLand: все действия LSP со списком и diff-превью каждого (delta)
            { "<leader>ca", function() require("tiny-code-action").code_action() end, desc = "Действия (с превью)", mode = { "n", "x" }, has = "codeAction" },
            -- Ctrl+Alt+M / V / N GoLand: только нужный вид рефакторинга
            { "<leader>cx", code_action("refactor.extract"), desc = "Вынести: функцию, переменную, константу", mode = { "n", "x" }, has = "codeAction" },
            { "<leader>ci", code_action("refactor.inline"), desc = "Встроить вызов / переменную", mode = { "n", "x" }, has = "codeAction" },
            { "<leader>cw", code_action("refactor.rewrite"), desc = "Переписать: fill struct, if↔else, параметры…", mode = { "n", "x" }, has = "codeAction" },
            -- Ctrl+Alt+H: кто вызывает функцию и кого вызывает она
            { "<leader>ch", "<cmd>Trouble lsp_incoming_calls toggle<cr>", desc = "Кто вызывает (иерархия)", has = "callHierarchy" },
            { "<leader>cH", "<cmd>Trouble lsp_outgoing_calls toggle<cr>", desc = "Кого вызывает (иерархия)", has = "callHierarchy" },
            -- F-клавиши GoLand (на HyperX — через Fn): Shift+F6 — переименовать, F2 — к следующей ошибке
            { "<S-F6>", function() return ":IncRename " .. vim.fn.expand("<cword>") end, expr = true, desc = "Переименовать (как в GoLand)", has = "rename" },
            { "<F2>", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end, desc = "Следующая ошибка" },
            { "<S-F2>", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end, desc = "Предыдущая ошибка" },
          },
        },
      },
    },
  },

  -- Меню действий с превью: что именно поменяется, видно до применения
  {
    "rachartier/tiny-code-action.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "LspAttach",
    opts = { backend = "delta", picker = "snacks" },
  },

  -- «реализует: io.Reader, fmt.Stringer» рядом с типом, «реализуют: …» рядом с интерфейсом — значки ↑↓ GoLand
  {
    "maxandron/goplements.nvim",
    ft = "go",
    opts = {
      prefix = { interface = "реализуют: ", struct = "реализует: " },
      display_package = true,
      highlight = "Goplements",
    },
  },

  -- Генерация, как Alt+Insert / Alt+Enter в GoLand: теги, реализация интерфейса, тесты, if err
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    -- gomodifytags, impl, gotests, iferr ставятся через go install; руками — :GoInstallDeps
    build = function() require("gopher").install_deps({ sync = true }) end,
    opts = {},
    keys = {
      { "<leader>G", "", desc = "+go", ft = "go" },
      { "<leader>Gj", "<cmd>GoTagAdd json<cr>", desc = "Теги json у полей", ft = "go" },
      { "<leader>Gy", "<cmd>GoTagAdd yaml<cr>", desc = "Теги yaml", ft = "go" },
      { "<leader>Gd", "<cmd>GoTagAdd db<cr>", desc = "Теги db", ft = "go" },
      { "<leader>Gt", prompt("Какие теги добавить (json,validate…): ", "GoTagAdd"), desc = "Теги: свои", ft = "go" },
      { "<leader>Gr", "<cmd>GoTagRm<cr>", desc = "Убрать теги", ft = "go" },
      { "<leader>Gi", prompt("Какой интерфейс реализовать (io.Reader, http.Handler…): ", "GoImpl"), desc = "Реализовать интерфейс (курсор на типе)", ft = "go" },
      { "<leader>Ge", "<cmd>GoIfErr<cr>", desc = "if err != nil { return … }", ft = "go" },
      { "<leader>Gc", "<cmd>GoCmt<cr>", desc = "Doc-комментарий", ft = "go" },
      { "<leader>Gf", "<cmd>GoTestAdd<cr>", desc = "Тест для функции под курсором", ft = "go" },
      { "<leader>GF", "<cmd>GoTestsAll<cr>", desc = "Тесты для всех функций файла", ft = "go" },
      { "<leader>Gm", "<cmd>GoMod tidy<cr>", desc = "go mod tidy", ft = "go" },
      { "<leader>Gg", prompt("go get: ", "GoGet"), desc = "go get пакет", ft = "go" },
      -- вставить JSON (ответ API, пример из доки) → готовая структура с тегами json
      { "<leader>Gp", "<cmd>GoJson<cr>", desc = "JSON → Go-структура", ft = "go" },
      -- что ушло в кучу, что заинлайнилось — подсказки компилятора прямо в коде (пакет целиком); ещё раз — убрать
      { "<leader>Go", code_action("source.toggleCompilerOptDetails"), desc = "Оптимизации компилятора: куча / инлайн", ft = "go" },
    },
  },

  -- Peek, как Ctrl+Shift+I: определение / использования / реализации во всплывающем окне, без перехода
  {
    "dnlhc/glance.nvim",
    cmd = "Glance",
    opts = { border = { enable = true }, theme = { enable = true, mode = "auto" } },
    keys = {
      { "gp", "", desc = "+посмотреть (peek)" },
      { "gpd", "<cmd>Glance definitions<cr>", desc = "Определение" },
      { "gpr", "<cmd>Glance references<cr>", desc = "Использования" },
      { "gpi", "<cmd>Glance implementations<cr>", desc = "Реализации" },
      { "gpt", "<cmd>Glance type_definitions<cr>", desc = "Тип" },
    },
  },

  -- Покрытие слева от кода: зелёное — тесты прошли по строке, красное — нет (Run with Coverage)
  {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide", "CoverageToggle", "CoverageSummary" },
    opts = {
      auto_reload = true,
      lang = { go = { coverage_file = "/tmp/cover.out" } }, -- тот же файл, что у задачи «покрытие тестами»
      signs = { covered = { text = "▎" }, uncovered = { text = "▎" }, partial = { text = "▎" } },
    },
    keys = {
      {
        "<leader>Gv",
        function()
          vim.notify("go test -cover ./… — жду тесты")
          vim.system({ "go", "test", "-coverprofile=/tmp/cover.out", "./..." }, { cwd = LazyVim.root(), text = true }, vim.schedule_wrap(function(res)
            if res.code ~= 0 then vim.notify("часть тестов упала — покрытие по тем, что прошли", vim.log.levels.WARN) end
            require("coverage").load(true)
          end))
        end,
        desc = "Покрытие: прогнать тесты и показать",
      },
      { "<leader>GV", "<cmd>CoverageToggle<cr>", desc = "Покрытие: спрятать / показать" },
      { "<leader>Gs", "<cmd>CoverageSummary<cr>", desc = "Покрытие: проценты по файлам" },
    },
  },

  -- ▶ у func main и тестов (lua/dotfiles/run.lua)
  {
    "LazyVim/LazyVim",
    init = function() require("dotfiles.run").setup() end,
    keys = {
      { "<leader>rx", function() require("dotfiles.run").run(false) end, desc = "▶ Запустить функцию под курсором (main / тест)" },
      { "<leader>rX", function() require("dotfiles.run").run(true) end, desc = "▶ То же под отладчиком" },
    },
  },

  -- Отладка: подключиться к dlv в контейнере. В Dockerfile/compose:
  --   dlv debug ./cmd/api --headless --listen=:2345 --accept-multiclient --api-version=2
  -- и порт 2345 наружу. Код в контейнере — в /app (поменять: substitutePath ниже).
  {
    "leoluz/nvim-dap-go",
    optional = true,
    opts = {
      dap_configurations = {
        {
          type = "go",
          name = "Подключиться к dlv в Docker (:2345)",
          mode = "remote",
          request = "attach",
          host = "127.0.0.1",
          port = "2345",
          substitutePath = { { from = "${workspaceFolder}", to = "/app" } },
        },
      },
    },
  },
}
