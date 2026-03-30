-- Table of themes and whether background should be transparent
local THEMES = {
  default = false,
  habamax = true,
  vscode = true,
  slate = false,
  sorbet = false,
  torte = false,
  unokai = true,
}

local colorschemes = {}
for colorscheme, _ in pairs(THEMES) do
  table.insert(colorschemes, colorscheme)
end

local function set_theme(colorscheme)
  print("today's theme:", colorscheme)
  vim.cmd.colorscheme(colorscheme)
  if THEMES[colorscheme] then
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
  end
end

set_theme('vscode')

-- -- Change theme every day based on day file
--
-- local real_daystr = vim.fn.strftime("%Y%m%d")
-- local dayfile_path = vim.fs.joinpath(vim.fn.stdpath('cache'), "dayfile")
--
-- local function get_todays_colorscheme()
--   local file_r = io.open(dayfile_path, "r")
--   if not file_r then
--     return nil
--   end
--
--   local stored_daystr = file_r:read('l')
--   local colorscheme = file_r:read('l')
--   file_r:close()
--
--   if not vim.tbl_contains(colorschemes, colorscheme) or stored_daystr ~= real_daystr then
--     return nil
--   end
--   return colorscheme
-- end
--
-- local colorscheme = get_todays_colorscheme()
-- if not colorscheme then
--   colorscheme = colorschemes[math.random(1, #colorschemes)]
--   local file_w = assert(io.open(dayfile_path, "w"))
--   file_w:write(real_daystr, "\n", colorscheme)
--   file_w:close()
-- end
-- set_theme(colorscheme)
