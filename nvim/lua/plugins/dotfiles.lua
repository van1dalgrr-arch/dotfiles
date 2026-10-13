-- Своё поверх LazyVim. Всё остальное — из коробки: https://lazyvim.org
return {
  -- тема в тон терминалу (Neon Noir / Dev Night): тёмная, фиолетовые акценты
  { "folke/tokyonight.nvim", opts = { style = "night", transparent = true } },
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
}
