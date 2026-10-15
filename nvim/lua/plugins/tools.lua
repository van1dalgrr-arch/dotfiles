-- Инструменты: Claude одной клавишей, gw, yazi, Go-черновик, структурная замена, правка списка ошибок,
-- точки останова, которые переживают перезапуск.
local function claude_fix()
  local lnum = vim.fn.line(".")
  local diags = vim.diagnostic.get(0, { lnum = lnum - 1 })
  if #diags == 0 then return vim.notify("на этой строке нет ошибок — курсор на строку с ошибкой", vim.log.levels.WARN) end
  local msgs = vim.tbl_map(function(d) return d.message:gsub("\n", " ") end, diags)
  local text = ("Почини проблему в %s:%d — %s. Объясни коротко, в чём была ошибка.")
    :format(vim.fn.expand("%:."), lnum, table.concat(msgs, "; "))
  local term = require("claudecode.terminal")
  if term.get_active_terminal_bufnr() then
    term.ensure_visible()
    return term.send_to_terminal(text, { submit = true })
  end
  -- Claude ещё не запущен: открыть и дать ему пару секунд проснуться
  term.open()
  vim.defer_fn(function() term.send_to_terminal(text, { submit = true }) end, 3000)
end

-- Go-черновик, как Go Playground: свой модуль в ~/.local/share/nvim/go-scratch, пробел r x — запустить
local function go_scratch()
  local dir = vim.fn.stdpath("data") .. "/go-scratch"
  local file = dir .. "/main.go"
  if not vim.uv.fs_stat(file) then
    vim.fn.mkdir(dir, "p")
    vim.fn.writefile({ "module scratch", "", "go " .. (vim.fn.system({ "go", "env", "GOVERSION" }):match("go([%d%.]+)") or "1.24") }, dir .. "/go.mod")
    vim.fn.writefile({ "package main", "", 'import "fmt"', "", "func main() {", '\tfmt.Println("черновик")', "}" }, file)
  end
  vim.cmd.edit(file)
end

return {
  -- Claude: alt-c — спрятать/показать откуда угодно (и из самой панели Claude); пробел a x — «почини ошибку под курсором»
  {
    "coder/claudecode.nvim",
    optional = true,
    keys = {
      { "<M-c>", function() require("claudecode.terminal").simple_toggle() end, mode = { "n", "t", "i" }, desc = "Claude: спрятать / показать" },
      { "<M-с>", function() require("claudecode.terminal").simple_toggle() end, mode = { "n", "t", "i" }, desc = "Claude: спрятать / показать" },
      { "<leader>ax", claude_fix, desc = "Claude: почини ошибку под курсором" },
    },
  },

  -- gw (github-watcher) во всплывающем окне: PR, Actions, логи CI. alt-w ещё раз — спрятать
  {
    "LazyVim/LazyVim",
    keys = {
      { "<leader>gw", function() require("dotfiles.system").gw() end, desc = "gw — GitHub: PR, Actions, логи" },
      { "<M-w>", function() require("dotfiles.system").gw() end, mode = { "n", "t" }, desc = "gw — GitHub" },
      { "<M-ц>", function() require("dotfiles.system").gw() end, mode = { "n", "t" }, desc = "gw — GitHub" },
      { "<leader>rg", go_scratch, desc = "Go-черновик (пробел r x — запустить)" },
    },
  },

  -- yazi вместо дерева, когда нужно поработать с файлами: превью, массовое переименование, те же клавиши
  {
    "mikavilpas/yazi.nvim",
    cmd = "Yazi",
    opts = { open_for_directories = false, floating_window_scaling_factor = 0.85 },
    keys = {
      { "<leader>fy", "<cmd>Yazi<cr>", desc = "yazi — у текущего файла" },
      { "<leader>fY", "<cmd>Yazi cwd<cr>", desc = "yazi — корень проекта" },
    },
  },

  -- Структурная замена (как Structural Search & Replace в GoLand) — по смыслу кода, а не по тексту:
  --   найти   errors.New(fmt.Sprintf($$$A))   заменить   fmt.Errorf($$$A)
  {
    "MagicDuck/grug-far.nvim",
    optional = true,
    keys = {
      {
        "<leader>sA",
        function()
          require("grug-far").open({ engine = "astgrep", prefills = { filesFilter = vim.bo.filetype == "go" and "*.go" or nil } })
        end,
        desc = "Структурная замена (ast-grep)",
      },
    },
  },
  -- ast-grep ставится из Brewfile

  -- Список ошибок / результатов поиска (quickfix) правится как текст — правки уходят в файлы
  { "stevearc/quicker.nvim", ft = "qf", opts = {} },

  -- Точки останова переживают перезапуск nvim, как в GoLand
  {
    "Weissle/persistent-breakpoints.nvim",
    event = "LazyFile",
    opts = { load_breakpoints_event = { "BufReadPost" } },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    keys = {
      { "<leader>db", function() require("persistent-breakpoints.api").toggle_breakpoint() end, desc = "Точка останова" },
      { "<leader>dB", function() require("persistent-breakpoints.api").set_conditional_breakpoint() end, desc = "Точка останова с условием" },
    },
  },
}
