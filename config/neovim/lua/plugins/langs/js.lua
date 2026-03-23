return {

  servers = {
    -- ts_ls is not fully released yet so we'll use vtsls for now
    -- ts_ls = { enabled = false },
    vtsls = {
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
      },
      settings = {
        complete_function_calls = true,
        vtsls = {
          enableMoveToFileCodeAction = true,
          autoUseWorkspaceTsdk = true,
          experimental = {
            maxInlayHintLength = 30,
            completion = {
              enableServerSideFuzzyMatch = true,
            },
          },
        },
        typescript = {
          updateImportsOnFileMove = { enabled = 'always' },
          suggest = {
            completeFunctionCalls = true,
          },
          inlayHints = {
            enumMemberValues = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            parameterNames = { enabled = 'literals' },
            parameterTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            variableTypes = { enabled = false },
          },
        },
      },
    },
    tailwindcss = {},
    -- eslint could also be added here if you want more functionality than the eslint_d (below)
  },

  plugins = {
    {
      'windwp/nvim-ts-autotag',
      config = function()
        require('nvim-ts-autotag').setup({
          opts = {
            enable_close = true,
            enable_rename = true,
            enable_close_on_slash = false,
          },
          per_filetype = {
            ['html'] = {
              enable_close = false,
            },
          },
        })
      end,
    },
  },

  parsers = {
    'javascript',
    'jsdoc',
    'tsx',
    'typescript',
  },

  formatters_by_ft = {
    javascript = { 'prettierd' },
    typescript = { 'prettierd' },
    javascriptreact = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    css = { 'prettierd' },
    json = { 'prettierd' },
    html = { 'prettierd' },
  },

  linters_by_ft = {
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    javascriptreact = { 'eslint_d' },
    typescriptreact = { 'eslint_d' },
  },
}
