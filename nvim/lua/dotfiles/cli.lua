-- Модули nvim из командной строки — для Rune (bin/rune-ide), чтобы логика жила в одном месте:
--   nvim --clean --headless -l cli.lua <команда> [аргументы]
-- endpoints <корень> · httpfile <корень> · http <файл> <строка> · review <папка>
local here = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
package.path = here .. "../?.lua;" .. package.path

local cmd = arg[1]
local code = 0
if cmd == "endpoints" then
  code = require("dotfiles.endpoints").cli(arg[2])
elseif cmd == "httpfile" then
  -- готовый api.http не трогаем: в нём твои тела запросов и правки
  local dest = arg[2] .. "/api.http"
  if not vim.uv.fs_stat(dest) then
    vim.notify = function(msg) io.stderr:write(msg, "\n") end
    dest = require("dotfiles.endpoints").http_file(arg[2], dest, true) or dest
  end
  io.stdout:write(dest, "\n")
elseif cmd == "http" then
  code = require("dotfiles.http").cli(arg[2], tonumber(arg[3]) or 1)
elseif cmd == "review" then
  code = require("dotfiles.review").cli(arg[2])
else
  io.stderr:write("команды: endpoints <корень> | httpfile <корень> | http <файл> <строка> | review <папка>\n")
  code = 2
end
os.exit(code)
