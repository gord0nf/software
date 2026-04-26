return {
  parsers = {
    'bash',
    'diff',
    'html',
    'json',
    'markdown',
    'markdown_inline',
    'printf',
    'query',
    'regex',
    'toml',
    'vim',
    'vimdoc',
    'xml',
    'yaml',
  },

  servers = {
    jsonls = {},
    bashls = {},
  },

  formatters_by_ft = {
    bash = { 'shfmt' },
    sh = { 'shfmt' },
  },

  plugins = {
    {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = function(_, opts)
        local npairs = require('nvim-autopairs')
        npairs.setup(opts)

        -- Custom rules
        local Rule = require('nvim-autopairs.rule')
        local cond = require('nvim-autopairs.conds')
        npairs.add_rules({
          Rule('<', '>'):with_pair(cond.not_before_regex('[<%s=]')),
        })
      end,
    },
  },
}
