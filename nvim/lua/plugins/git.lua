-- Git как в GoLand: трёхпанельный merge, история файла, diff ветки, blame. lazygit — пробел g g, как было.
local function default_branch()
  local ref = vim.fn.systemlist({ "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" })[1]
  return vim.v.shell_error == 0 and ref or "main"
end

local close = { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Закрыть diffview" } }

return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    opts = {
      enhanced_diff_hl = true,
      -- конфликт: слева «наше», справа «их», снизу результат — как Merge в GoLand
      view = { merge_tool = { layout = "diff3_mixed", disable_diagnostics = true } },
      keymaps = { view = { close }, file_panel = { close }, file_history_panel = { close } },
    },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview: все изменения / конфликты" },
      { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: история файла" },
      { "<leader>gR", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: история репозитория" },
      { "<leader>gm", function() vim.cmd("DiffviewOpen " .. default_branch() .. "...HEAD") end, desc = "Diffview: ветка против main (как PR)" },
      { "<leader>gV", "<cmd>DiffviewClose<cr>", desc = "Diffview: закрыть" },
    },
  },

  -- кто и когда менял строку — серым справа, как Annotate (включить: пробел u B)
  {
    "lewis6991/gitsigns.nvim",
    optional = true,
    opts = { current_line_blame_opts = { delay = 300, virt_text_pos = "eol" }, current_line_blame_formatter = "   <author>, <author_time:%d.%m.%Y> · <summary>" },
  },

  -- Local History GoLand: дерево всех правок файла, даже без git. Правки переживают закрытие nvim (undofile),
  -- а с автосохранением это единственный способ вернуть, что было 20 минут назад.
  {
    "LazyVim/LazyVim",
    keys = {
      {
        "<leader>U",
        function()
          vim.cmd.packadd("nvim.undotree") -- встроен в nvim 0.12
          require("undotree").open({ command = "topleft 40vnew" })
        end,
        desc = "История правок файла (undotree)",
      },
    },
  },
}
