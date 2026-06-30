-- 4 space tab width for nginx.conf
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'nginx' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

return {
  servers = {
    nginx_language_server = {
      command = { 'nginx-language-server' },
      filetypes = { 'nginx' },
      rootPatterns = { 'nginx.conf', '.git' },
    },
  },

  parsers = { 'nginx' },

  formatters = { ['nginx-config-formatter'] = {} },
  formatters_by_ft = {
    nginx = { mason = false, 'nginxfmt' },
  },
}
