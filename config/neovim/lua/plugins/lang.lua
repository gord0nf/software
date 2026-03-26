-- Each file in the plugins/langs/ directory represents all the lang stuff required for that
-- particular language. Then you can selectively enable/disable langs here!
--
-- Specifically, each returns a table with entries:
--  - servers:          Table of { ls_name: ls_opts } for nvim-lsp
--  - plugins:          Array of Lazy plugins to install
--  - parsers:          Array of names of Treesitter parsers to install
--  - formatters_by_ft: Table of { ft: formatters } for Conform
--  - linters_by_ft:    Table of { ft: linters } for nvim-lint

ENABLED_LANGS = { 'default', 'lua', 'js', 'go', 'java' } -- must be a name in the plugins/lsp/ dir

local merge_tables = require('utils').merge_tables
local concat_tables = require('utils').concat_tables

local aggregated_stuff = {
  servers = {}, -- Table of { ls_name: ls_opts } for nvim-lsp
  plugins = {}, -- Array of Lazy plugins to install
  parsers = {}, -- Array of names of Treesitter parsers to install
  formatters_by_ft = {}, -- Table of { ft: formatters } for Conform
  linters_by_ft = {}, -- Table of { ft: linters } for nvim-lint
}
for _, lang in ipairs(ENABLED_LANGS) do
  local l = require('plugins.langs.' .. lang)
  merge_tables(aggregated_stuff.servers, l.servers or {})
  concat_tables(aggregated_stuff.plugins, l.plugins or {})
  concat_tables(aggregated_stuff.parsers, l.parsers or {})
  merge_tables(aggregated_stuff.formatters_by_ft, l.formatters_by_ft or {})
  merge_tables(aggregated_stuff.linters_by_ft, l.linters_by_ft or {})
end

-- Core lang plugins
local plugins = {

  ------- LSP -------------------------------------------------------------------------------------
  {
    'mason-org/mason.nvim',
    config = function()
      require('mason').setup({})
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason-lspconfig.nvim' },
    config = function()
      local mlsp = require('mason-lspconfig')
      local available = {}
      do
        local ok, result = pcall(mlsp.get_available_servers)
        if ok then
          available = result
        else
          vim.schedule(function()
            vim.notify('[mason-lspconfig] Failed to get available servers: ' .. tostring(result), vim.log.levels.WARN)
          end)
          available = {}
        end
      end

      local ensure_installed = {}
      for server, server_opts in pairs(aggregated_stuff.servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          if server_opts.mason ~= false and vim.tbl_contains(available, server) then
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end
      for _, stuff_key in ipairs({ 'formatters_by_ft', 'linters_by_ft' }) do
        for _, tools in pairs(aggregated_stuff[stuff_key]) do
          for _, tool in ipairs(tools) do
            if not vim.tbl_contains(ensure_installed, tool) then
              ensure_installed[#ensure_installed + 1] = tool
            end
          end
        end
      end

      require('mason-tool-installer').setup({
        ensure_installed = ensure_installed,
        run_on_start = true,
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      local blink = require('blink.cmp')
      for server, server_opts in pairs(aggregated_stuff.servers) do
        server_opts.capabilities = blink.get_lsp_capabilities(server_opts.capabilities or {})
        vim.lsp.config(server, server_opts)
        vim.lsp.enable(server)
      end
    end,
  },

  ------- TREESITTER ------------------------------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    opts = { ensure_installed = aggregated_stuff.parsers },
    config = function()
      -- Highlighting
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '*' },
        callback = function()
          local filetype = vim.bo.filetype
          if filetype and filetype ~= '' then
            local success = pcall(function()
              vim.treesitter.start()
            end)
            if not success then
              return
            end
          end
        end,
      })
      -- Folds
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'
      vim.o.foldlevelstart = 99 -- when opening buffer, do not collapse folds
      vim.o.foldcolumn = 'auto:3'
      -- Indentation
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  },

  ------- FORMATTER -------------------------------------------------------------------------------
  {
    'stevearc/conform.nvim',
    opts = {},
    config = function()
      require('conform').setup({
        formatters_by_ft = aggregated_stuff.formatters_by_ft,
        format_on_save = {
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        },
      })
    end,
  },

  ------- LINTER ----------------------------------------------------------------------------------
  {
    'mfussenegger/nvim-lint',
    event = {
      'BufReadPre',
      'BufNewFile',
    },
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = aggregated_stuff.linters_by_ft
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      vim.keymap.set('n', '<leader>l', function()
        lint.try_lint()
      end, { desc = 'Trigger linting for current file' })
    end,
  },
}

concat_tables(plugins, aggregated_stuff.plugins)

return plugins
