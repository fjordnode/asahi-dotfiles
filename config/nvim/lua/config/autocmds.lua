-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Live theme reload: poll Omarchy theme.name for changes
_G._omarchy_last_theme = nil

local function read_theme_name()
  local f = io.open(vim.fn.expand("~/.config/omarchy/current/theme.name"), "r")
  if not f then return nil end
  local name = f:read("*l")
  f:close()
  return name
end

local function apply_omarchy_theme()
  local nvim_lua = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
  if vim.fn.filereadable(nvim_lua) ~= 1 then return end
  for line in io.lines(nvim_lua) do
    local cs = line:match('colorscheme%s*=%s*"([^"]+)"')
    if cs then
      pcall(vim.cmd.colorscheme, cs)
      return
    end
  end
end

local function check_theme()
  local current = read_theme_name()
  if current and current ~= _G._omarchy_last_theme then
    _G._omarchy_last_theme = current
    apply_omarchy_theme()
  end
end

_G._omarchy_last_theme = read_theme_name()
vim.fn.timer_start(3000, check_theme, { ["repeat"] = -1 })
