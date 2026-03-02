-- Load colorscheme from Omarchy's current theme
local theme_file = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
if vim.fn.filereadable(theme_file) == 1 then
  return dofile(theme_file)
end
return {}
