-- Postman в файле: .http-запросы через curl, без плагинов и лицензий (kulala с 2026 требует токен).
-- Формат как в VS Code REST Client / JetBrains HTTP Client:
--   @host = http://localhost:8080            переменная файла → {{host}}
--   ### Заголовок                            разделитель запросов
--   # @name login                            имя: ответ доступен как {{login.response.body.$.access_token}}
--   POST {{host}}/auth/login                 метод и адрес
--   Content-Type: application/json           заголовки до пустой строки, дальше — тело
local M = {}

local responses = {} -- имя запроса → разобранный JSON ответа
local last           -- последний отправленный запрос (для повтора)

-- блоки запросов файла: { name, method, url, headers = {}, body, first, last } + переменные
function M.parse(lines)
  local vars, reqs, cur = {}, {}, nil
  local function close(i)
    if cur then cur.last = i; reqs[#reqs + 1] = cur end
    cur = nil
  end
  local stage -- nil — до запроса, "headers", "body"
  for i, line in ipairs(lines) do
    if line:match("^###") then
      close(i - 1); stage = nil
    else
      local k, v = line:match("^@([%w_%-]+)%s*=%s*(.-)%s*$")
      if k and stage == nil then
        vars[k] = v
      elseif stage == nil then
        local name = line:match("^#%s*@name%s+([%w_%-]+)")
        local method, url = line:match("^(%u+)%s+(%S+)")
        if name then
          cur = cur or { first = i, headers = {}, body = {} }; cur.name = name
        elseif method then
          cur = cur or { first = i, headers = {}, body = {} }
          cur.method, cur.url, cur.line, stage = method, url, i, "headers"
        end
      elseif stage == "headers" then
        if line:match("^%s*$") then stage = "body"
        elseif not line:match("^%s*#") then
          local hk, hv = line:match("^([%w%-]+):%s*(.*)$")
          if hk then cur.headers[#cur.headers + 1] = { hk, hv } end
        end
      else
        cur.body[#cur.body + 1] = line
      end
    end
  end
  close(#lines)
  for _, r in ipairs(reqs) do
    while #r.body > 0 and r.body[#r.body]:match("^%s*$") do r.body[#r.body] = nil end
    r.body = table.concat(r.body, "\n")
  end
  return reqs, vars
end

-- {{host}}, {{login.response.body.$.a.b}}, {{$env.HOME}}
local function expand(s, vars)
  for _ = 1, 5 do -- переменные могут ссылаться друг на друга
    local before = s
    s = s:gsub("{{%s*(.-)%s*}}", function(key)
      if vars[key] then return vars[key] end
      local env = key:match("^%$env%.([%w_]+)$")
      if env then return os.getenv(env) or "" end
      local name, path = key:match("^([%w_%-]+)%.response%.body%.%$%.?(.*)$")
      local v = name and responses[name]
      if v == nil then return nil end
      for part in path:gmatch("[^%.]+") do
        v = type(v) == "table" and v[tonumber(part) and tonumber(part) + 1 or part] or nil
      end
      return v ~= nil and tostring(v) or nil
    end)
    if s == before then break end
  end
  return s
end

local function curl_args(r, vars)
  local args = { "curl", "-s", "-S", "--connect-timeout", "5", "--max-time", "30", "-X", r.method, "-w", "\n@@%{http_code} %{time_total}" }
  for _, h in ipairs(r.headers) do vim.list_extend(args, { "-H", h[1] .. ": " .. expand(h[2], vars) }) end
  if r.body ~= "" then vim.list_extend(args, { "--data-binary", expand(r.body, vars) }) end
  args[#args + 1] = expand(r.url, vars)
  return args
end

-- одна панель ответа справа: открыта — перерисовывается, закрыта — открывается заново
local win, buf
local function show(lines)
  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "json"
    vim.api.nvim_buf_set_name(buf, "http-ответ")
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "закрыть ответ" })
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  if not (win and vim.api.nvim_win_is_valid(win)) then
    local from = vim.api.nvim_get_current_win()
    vim.cmd("botright vsplit")
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_set_current_win(from)
  end
end

local function run(r, vars)
  last = { r = r, vars = vars }
  local args = curl_args(r, vars)
  local url = args[#args]
  vim.system(args, { text = true }, vim.schedule_wrap(function(res)
    if res.code ~= 0 then
      return show({ "// " .. r.method .. " " .. url .. " → нет ответа", "// " .. vim.trim(res.stderr or ""), "// API запущен? пробел r r → go run / up" })
    end
    local out, status, secs = res.stdout:match("^(.*)\n@@(%d+) ([%d.]+)$")
    out = out or res.stdout
    local ok, decoded = pcall(vim.json.decode, out)
    if ok and type(decoded) == "table" then
      if r.name then responses[r.name] = decoded end
      if vim.fn.executable("jq") == 1 then out = table.concat(vim.fn.systemlist({ "jq", "." }, out), "\n") end
    end
    local ms = (tonumber(secs) or 0) * 1000
    local head = ("// %s %s → %s · %s"):format(r.method, url, status or "?", ms < 1 and "<1 мс" or ("%d мс"):format(math.floor(ms)))
    show(vim.list_extend({ head }, vim.split(out, "\n")))
  end))
end

-- запрос под курсором (или ближайший выше)
local function current()
  local reqs, vars = M.parse(vim.api.nvim_buf_get_lines(0, 0, -1, false))
  local line = vim.fn.line(".")
  for i = #reqs, 1, -1 do
    if reqs[i].method and reqs[i].first <= line then return reqs[i], vars, reqs end
  end
  return nil, vars, reqs
end

function M.send()
  local r, vars = current()
  if not r then return vim.notify("курсор не на запросе", vim.log.levels.WARN) end
  run(r, vars)
end

function M.replay()
  if not last then return vim.notify("ещё ничего не отправлялось", vim.log.levels.WARN) end
  run(last.r, last.vars)
end

function M.copy_curl()
  local r, vars = current()
  if not r then return end
  local args = vim.tbl_filter(function(a) return a ~= "-w" and not a:match("^\n@@") end, curl_args(r, vars))
  local cmd = table.concat(vim.tbl_map(vim.fn.shellescape, args), " ")
  vim.fn.setreg("+", cmd)
  vim.notify(cmd, vim.log.levels.INFO, { title = "скопировано" })
end

function M.jump(dir)
  local reqs = select(3, current())
  local line = vim.fn.line(".")
  local targets = vim.tbl_map(function(r) return r.line end, vim.tbl_filter(function(r) return r.line end, reqs))
  if dir < 0 then targets = vim.fn.reverse(targets) end
  for _, l in ipairs(targets) do
    if (dir > 0 and l > line) or (dir < 0 and l < line) then return vim.api.nvim_win_set_cursor(0, { l, 0 }) end
  end
end

M._responses, M._curl_args = responses, curl_args
return M
