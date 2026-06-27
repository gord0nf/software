vim.opt.termguicolors = true

-- Cursor
vim.opt.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'

-- Color column jazz
vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = '100'

-- Markdown header colors for github theme
if Settings.theme and Settings.theme:find('github', 1, true) == 1 then
  local palette = require('github-theme.palette').load(Settings.theme)
  vim.api.nvim_set_hl(0, '@markup.heading.1.markdown', { fg = palette.blue.bright, bold = true })
  vim.api.nvim_set_hl(0, '@markup.heading.2.markdown', { fg = palette.yellow.bright, bold = true })
  vim.api.nvim_set_hl(0, '@markup.heading.3.markdown', { fg = palette.magenta.bright, bold = true })
  vim.api.nvim_set_hl(0, '@markup.heading.4.markdown', { fg = palette.red.bright, bold = true })
  vim.api.nvim_set_hl(0, '@markup.heading.5.markdown', { fg = palette.green.bright, bold = true })
  vim.api.nvim_set_hl(0, '@markup.heading.6.markdown', { fg = palette.cyan.bright, bold = true })
end
