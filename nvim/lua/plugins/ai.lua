-- То, чего в GoLand нет: Claude Code внутри редактора и Kubernetes в соседней вкладке.
return {
  -- Claude Code (extra ai.claudecode в lazyvim.json): видит открытый файл и выделение,
  -- правки показывает diff-ом прямо в nvim — пробел a a принять, пробел a d отклонить.
  -- Claude, запущенный в отдельном окне Ghostty, подключается к этому nvim командой /ide.
  {
    "coder/claudecode.nvim",
    optional = true,
    opts = {
      terminal = { split_side = "right", split_width_percentage = 0.4, provider = "snacks" },
      diff_opts = { open_in_new_tab = false, keep_terminal_focus = false },
    },
  },

  -- Kubernetes, как k9s: поды, логи, describe, port-forward — пробел k. Только если стоит kubectl.
  {
    "ramilito/kubectl.nvim",
    version = "2.*",
    cond = vim.fn.executable("kubectl") == 1,
    dependencies = { "saghen/blink.download" },
    cmd = { "Kubectl", "Kubens", "Kubectx" },
    opts = {},
    keys = {
      { "<leader>k", function() require("kubectl").toggle({ tab = true }) end, desc = "Kubernetes (kubectl.nvim)" },
    },
  },
}
