-- Задачи как в Zed (zed/tasks.json): пробел r r — список, пробел r l — что запущено, пробел r d — lazydocker.
-- Тест под курсором и lazygit в LazyVim уже есть: пробел t r и пробел g g.
local function root() return LazyVim.root() end
local function file_dir() return vim.fn.expand("%:p:h") end
local function image() -- имя образа как в Zed: папка проекта в нижнем регистре, пробелы → дефисы
  return vim.fn.fnamemodify(root(), ":t"):lower():gsub(" ", "-") .. ":dev"
end
local function has(file) return function(search) return vim.uv.fs_stat(search.dir .. "/" .. file) ~= nil end end
local function any(...)
  local files = { ... }
  return function(search)
    for _, f in ipairs(files) do if vim.uv.fs_stat(search.dir .. "/" .. f) then return true end end
    return false
  end
end

-- { имя, команда (строка — через shell; функция — собирается в момент запуска), условие }
local go, compose, docker = has("go.mod"), any("compose.yaml", "compose.yml", "docker-compose.yml", "docker-compose.yaml"), has("Dockerfile")
local tasks = {
  { "up — зависимости из compose + приложение", "zsh -ic up", go },
  { "air — hot reload", "air", go },
  { "go run ./cmd/api", "go run ./cmd/api", go },
  { "тесты — весь проект", "gotestsum --format pkgname-and-test-fails --format-icons hivis -- ./...", go },
  { "тесты — пакет текущего файла", function() return "gotestsum --format testname -- -count=1 " .. vim.fn.shellescape(file_dir()) end, go },
  { "покрытие тестами", "go test -coverprofile=/tmp/cover.out ./... && go tool cover -html=/tmp/cover.out", go },
  -- профиль CPU открывается в браузере (flame graph, top, исходник); бинарник теста — в /tmp, не в проект
  { "бенчмарки пакета + pprof", function() return "go test -run '^$' -bench . -benchmem -o /tmp/bench.test -cpuprofile /tmp/cpu.out " .. vim.fn.shellescape(file_dir()) .. " && go tool pprof -http=:0 /tmp/cpu.out" end, go },
  { "golangci-lint", "golangci-lint run ./...", go },
  { "go mod tidy", "go mod tidy", go },
  { "govulncheck", "govulncheck ./...", go },
  { "curl /health", "curl -s localhost:${PORT:-8080}/health | jq .", go },
  { "логи compose", "docker compose logs -f --tail 100", compose },
  { "docker compose up -d", "docker compose up -d --wait", compose },
  { "docker compose down", "docker compose down", compose },
  { "docker compose ps", "docker compose ps", compose },
  { "docker compose config", "docker compose config", compose },
  { "docker build — образ проекта", function() return "docker build -t " .. image() .. " ." end, docker },
  { "hadolint — текущий Dockerfile", function() return "hadolint " .. vim.fn.shellescape(vim.fn.expand("%:p")) end, docker },
  { "trivy — уязвимости образа", function() return "trivy image --severity HIGH,CRITICAL " .. image() end, docker },
  { "dot project doctor", function() return "dot project doctor " .. vim.fn.shellescape(root()) end },
  { "dot work — что поднято", "dot work" },
}

return {
  {
    "stevearc/overseer.nvim",
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)
      for _, t in ipairs(tasks) do
        local name, cmd, cond = t[1], t[2], t[3]
        overseer.register_template({
          name = name,
          builder = function()
            return { name = name, cmd = type(cmd) == "function" and cmd() or cmd, cwd = root() }
          end,
          condition = cond and { callback = cond } or nil,
        })
      end
    end,
    keys = {
      { "<leader>r", "", desc = "+run" },
      { "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Задачи (как ctrl-r в Zed)" },
      { "<leader>rl", "<cmd>OverseerToggle!<cr>", desc = "Что запущено" },
      { "<leader>rd", function() Snacks.terminal("lazydocker", { cwd = LazyVim.root() }) end, desc = "lazydocker" },
    },
  },
}
