-- Эндпоинты Gin, как окно Endpoints в GoLand: все маршруты проекта с полным путём.
-- Разбор по строкам, без запуска кода: `x := y.Group("/p")` копит префиксы, `x.GET("/q", h)` — маршрут.
-- Группы и маршруты, объявленные в разных файлах, склеиваются, если переменная группы — в том же файле.
local M = {}

local methods = { GET = true, POST = true, PUT = true, PATCH = true, DELETE = true, HEAD = true, OPTIONS = true, Any = true }

-- маршруты одного файла: { method, path, handler, file, line, col (с 0, на имени хендлера) }
local function parse(file, out)
  local prefix = {} -- переменная группы → её полный префикс
  for i, line in ipairs(vim.fn.readfile(file)) do
    local var, parent, p = line:match("([%w_]+)%s*:?=%s*([%w_%.]+)%.Group%(%s*\"([^\"]*)\"")
    if var then
      prefix[var] = (prefix[parent] or "") .. p
    else
      local recv, method, path, rest = line:match("([%w_]+)%.(%u%a+)%(%s*\"([^\"]*)\"(.*)")
      if recv and methods[method] then
        -- хендлер — последний аргумент: userHandler.Register, h.List, func(c *gin.Context)…
        local handler = rest:match(",%s*([%w_%.]+)%)%s*$") or rest:match(",%s*([%w_%.]+)%s*,?%s*$") or "func"
        local col = line:find(handler, 1, true)
        out[#out + 1] = {
          method = method:upper(),
          path = ((prefix[recv] or "") .. path):gsub("//+", "/"),
          handler = handler,
          file = file,
          line = i,
          col = col and (col - 1 + #handler - #(handler:match("[%w_]+$") or "")) or 0,
        }
      end
    end
  end
end

---@param root string
function M.collect(root)
  local files = vim.fn.systemlist({ "rg", "--files", "-g", "*.go", "-g", "!*_test.go", "-g", "!vendor/**", root })
  local out = {}
  for _, f in ipairs(files) do parse(f, out) end
  local order = { GET = 1, POST = 2, PUT = 3, PATCH = 4, DELETE = 5 }
  table.sort(out, function(a, b)
    if a.path ~= b.path then return a.path < b.path end
    return (order[a.method] or 9) < (order[b.method] or 9)
  end)
  return out
end

local colors = { GET = "DiagnosticOk", POST = "DiagnosticWarn", PUT = "DiagnosticInfo", PATCH = "DiagnosticInfo", DELETE = "DiagnosticError" }

function M.pick()
  local root = LazyVim.root()
  local routes = M.collect(root)
  if #routes == 0 then
    return vim.notify("Маршрутов Gin не нашёл в " .. root, vim.log.levels.WARN)
  end
  local items = {}
  for _, r in ipairs(routes) do
    items[#items + 1] = {
      text = r.method .. " " .. r.path .. " " .. r.handler,
      file = r.file,
      pos = { r.line, r.col },
      route = r,
    }
  end
  Snacks.picker.pick({
    title = "Эндпоинты · enter — хендлер · ctrl-y — curl",
    items = items,
    preview = "file",
    format = function(item)
      local r = item.route
      return {
        { ("%-7s"):format(r.method), colors[r.method] or "Special" },
        { r.path, "Title" },
        { "  → " .. r.handler, "Comment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      -- после закрытия списка: иначе текущим остаётся его окно, и gopls спрашивать не у кого
      vim.schedule(function()
        vim.cmd.edit(item.file)
        vim.api.nvim_win_set_cursor(0, item.pos)
        -- курсор на имени хендлера, дальше — к его определению через gopls.
        -- Только что открытый файл gopls подхватывает не сразу: тогда ждём, пока он подключится.
        local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
        local function jump(client)
          local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
          client:request("textDocument/definition", params, function(_, result)
            local loc = vim.islist(result) and result[1] or result
            if loc and vim.api.nvim_get_current_win() == win then
              vim.lsp.util.show_document(loc, client.offset_encoding, { focus = true })
            end
          end, buf)
        end
        local client = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/definition" })[1]
        if client then return jump(client) end
        vim.api.nvim_create_autocmd("LspAttach", {
          buffer = buf,
          once = true,
          callback = function(ev)
            local c = vim.lsp.get_client_by_id(ev.data.client_id)
            if c and c:supports_method("textDocument/definition") then jump(c) end
          end,
        })
      end)
    end,
    actions = {
      curl = function(_, item)
        local r = item.route
        local path = r.path:gsub(":([%w_]+)", "1"):gsub("%*[%w_]*", "")
        local cmd = ("curl -s -X %s localhost:${PORT:-8080}%s | jq ."):format(r.method == "ANY" and "GET" or r.method, path)
        vim.fn.setreg("+", cmd)
        vim.notify(cmd, vim.log.levels.INFO, { title = "скопировано" })
      end,
    },
    win = { input = { keys = { ["<c-y>"] = { "curl", mode = { "n", "i" } } } } },
  })
end

return M
