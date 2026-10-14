-- ◆ режим dot work в статусной строке (lua/dotfiles/system.lua)
return {
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      local sys = require("dotfiles.system")
      table.insert(opts.sections.lualine_x, 1, {
        sys.work_status,
        cond = function() return vim.uv.fs_stat(vim.fn.expand("~/.config/dotfiles/work")) ~= nil end,
        color = function() return { fg = Snacks.util.color("Special") } end,
      })
    end,
  },
}
