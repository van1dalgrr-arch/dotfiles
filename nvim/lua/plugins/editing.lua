-- Правка быстрее: surround, умный ctrl-a, история копирования — extras в lazyvim.json; здесь их настройка под Go
-- и маскировка секретов в .env.
return {
  -- ctrl-a / ctrl-x на слове под курсором — переключить на соседнее значение (в Go вдобавок к числам, true/false, &&/||)
  {
    "monaqa/dial.nvim",
    optional = true,
    opts = function(_, opts)
      local augend = require("dial.augend")
      local function cycle(elements, word)
        return augend.constant.new({ elements = elements, word = word ~= false, cyclic = true })
      end
      opts.dials_by_ft.go = "go"
      opts.groups.go = {
        cycle({ ":=", "=" }, false),
        cycle({ "==", "!=" }, false),
        cycle({ "var", "const" }),
        cycle({ "Error", "Fatal" }), -- t.Error ↔ t.Fatal
        cycle({ "Errorf", "Fatalf" }),
        cycle({ "Debug", "Info", "Warn" }), -- slog.Debug → Info → Warn (Error — уже в паре с Fatal)
        cycle({ "Println", "Printf", "Print" }),
        cycle({ "MethodGet", "MethodPost", "MethodPut", "MethodPatch", "MethodDelete" }),
        cycle({ "GET", "POST", "PUT", "PATCH", "DELETE" }),
        cycle({ "StatusOK", "StatusCreated", "StatusNoContent", "StatusBadRequest", "StatusUnauthorized", "StatusNotFound", "StatusInternalServerError" }),
      }
    end,
  },

  -- .env: значения скрыты звёздочками — пароли и токены не видно на экране и при демонстрации.
  -- Строка под курсором открыта; пробел u e — показать / спрятать всё.
  {
    "laytan/cloak.nvim",
    event = { "BufReadPre .env*", "BufReadPre *.env" },
    cmd = { "CloakToggle", "CloakPreviewLine" },
    opts = {
      cloak_telescope = false,
      patterns = { { file_pattern = { ".env*", "*.env" }, cloak_pattern = "=.+" } },
    },
    keys = {
      { "<leader>ue", "<cmd>CloakToggle<cr>", desc = "Секреты в .env: показать / спрятать" },
    },
    config = function(_, opts)
      require("cloak").setup(opts)
      -- строка под курсором открыта, остальные — под звёздочками
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = vim.api.nvim_create_augroup("dotfiles.cloak", { clear = true }),
        pattern = { ".env*", "*.env" },
        callback = function() pcall(vim.cmd, "CloakPreviewLine") end,
      })
    end,
  },
}
