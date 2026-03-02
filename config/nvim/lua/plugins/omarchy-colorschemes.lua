-- Pre-install all Omarchy colorscheme plugins so live theme switching works
return {
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "folke/tokyonight.nvim", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "EdenEast/nightfox.nvim", lazy = true },
  { "neanias/everforest-nvim", lazy = true },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
  { "bjarneo/hackerman.nvim", dependencies = { "bjarneo/aether.nvim" }, lazy = true },
  { "bjarneo/vantablack.nvim", lazy = true },
  { "bjarneo/white.nvim", lazy = true },
  { "bjarneo/ethereal.nvim", lazy = true },
  { "tahayvr/matteblack.nvim", lazy = true },
  { "xero/miasma.nvim", lazy = true },
  { "ribru17/bamboo.nvim", lazy = true },
  { "kepano/flexoki-neovim", lazy = true },
  { "gthelding/monokai-pro.nvim", lazy = true },
}
