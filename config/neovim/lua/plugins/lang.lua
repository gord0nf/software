-- Each file in the plugins/langs/ directory represents all the lang stuff required for that
-- particular language. Then you can selectively enable/disable langs here!
--
-- Specifically, each returns a table with entries:
--  - servers:          Table of { ls_name: ls_opts } for nvim-lsp
--  - plugins:          Array of Lazy plugins to install
--  - parsers:          Array of names of Treesitter parsers to install
--  - formatters:       Table of { formatter: opts } for Conform
--  - formatters_by_ft: Table of { ft: formatters } for Conform
--  - linters_by_ft:    Table of { ft: linters } for nvim-lint

ENABLED_LANGS = { 'default' } -- must be a name in the plugins/lsp/ dir
vim.list_extend(ENABLED_LANGS, Settings.langs or {})

local merge_tables = require('utils').merge_tables
local concat_tables = require('utils').concat_tables

local aggregated_stuff = {
  servers = {}, -- Table of { ls_name: ls_opts | func() -> ls_opts } for nvim-lsp
  plugins = {}, -- Array of Lazy plugins to install
  parsers = {}, -- Array of names of Treesitter parsers to install
  formatters = {}, -- Table of { formatter: opts } for Conform
  formatters_by_ft = {}, -- Table of { ft: formatters } for Conform
  linters_by_ft = {}, -- Table of { ft: linters } for nvim-lint
}
for _, lang in ipairs(ENABLED_LANGS) do
  local l = require('plugins.langs.' .. lang)
  merge_tables(aggregated_stuff.servers, l.servers or {})
  concat_tables(aggregated_stuff.plugins, l.plugins or {})
  concat_tables(aggregated_stuff.parsers, l.parsers or {})
  merge_tables(aggregated_stuff.formatters, l.formatters or {})
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
          if (type(server_opts) ~= 'table' or server_opts.mason ~= false) and vim.tbl_contains(available, server) then
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end
      for formatter, formatter_opts in pairs(aggregated_stuff.formatters) do
        if formatter_opts then
          formatter_opts = formatter_opts == true and {} or formatter_opts
          if type(formatter_opts) ~= 'table' or formatter_opts.mason ~= false then
            ensure_installed[#ensure_installed + 1] = formatter
          end
        end
      end
      for _, stuff_key in ipairs({ 'formatters_by_ft', 'linters_by_ft' }) do
        for _, tools in pairs(aggregated_stuff[stuff_key]) do
          if tools.mason == nil or tools.mason then
            for k, tool in ipairs(tools) do
              if k ~= 'mason' and not vim.tbl_contains(ensure_installed, tool) then
                ensure_installed[#ensure_installed + 1] = tool
              end
            end
          end
        end
      end

      if not vim.tbl_contains(ensure_installed, 'tree-sitter-cli') then
        ensure_installed[#ensure_installed + 1] = 'tree-sitter-cli'
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
        if type(server_opts) == 'function' then
          server_opts = server_opts()
        end

        server_opts.capabilities = blink.get_lsp_capabilities(server_opts.capabilities or {})
        vim.lsp.config(server, server_opts)
        vim.lsp.enable(server)
      end
    end,
  },

  ------- TREESITTER ------------------------------------------------------------------------------
  --- https://www.reddit.com/r/neovim/s/3rRffUiQIx
  {
    'nvim-treesitter/nvim-treesitter',
    commit = '90cd658',
    main = 'nvim-treesitter',
    -- build = ":TSUpdate",
    event = { 'BufReadPost', 'BufNewFile' },
    init = function()
      local highlight = function(bufnr, lang)
        -------------------[ treesitter highlights ]-------------------------------
        if not vim.treesitter.language.add(lang) then
          return vim.notify(
            string.format('Treesitter cannot load parser for language: %s', lang),
            vim.log.levels.INFO,
            { title = 'Treesitter' }
          )
        end
        vim.treesitter.start(bufnr)
      end

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local ft = vim.bo.filetype
          local bt = vim.bo.buftype
          local buf = args.buf

          if bt ~= '' then
            return
          end -- don't run further.

          local ok, treesitter = pcall(require, 'nvim-treesitter')
          if not ok then
            return
          end

          --------------------[ treesitter folds ]-------------------------------

          if ft == 'javascriptreact' or ft == 'typescriptreact' then
            vim.opt_local.foldmethod = 'indent'
          else
            vim.opt_local.foldmethod = 'expr'
            vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          end
          vim.opt.foldlevel = 99
          vim.o.foldlevelstart = 99
          vim.o.foldcolumn = 'auto:3'

          vim.schedule(function()
            -- Only run normal if we're not in terminal mode
            if vim.fn.mode() ~= 't' then
              vim.cmd 'silent! normal! zx'
            end
          end)

          ---------------------[ treesitter indent ]-------------------------------

          if not vim.tbl_contains({ 'python', 'html', 'yaml', 'markdown' }, ft) then
            vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
          end

          --------------------[ treesitter parsers ]-------------------------------
          if vim.fn.executable 'tree-sitter' ~= 1 then
            vim.api.nvim_echo({
              {
                'tree-sitter CLI not found. Parsers cannot be installed.',
                'ErrorMsg',
              },
            }, true, {})
            return false
          end

          if not vim.treesitter.language.get_lang(ft) then
            return
          end

          if vim.list_contains(treesitter.get_installed(), ft) then
            highlight(buf, ft)
          elseif vim.list_contains(treesitter.get_available(), ft) then
            treesitter.install(ft):await(function()
              highlight(buf, ft)
            end)
          end
        end,
      })
    end,
    opts = { install = aggregated_stuff.parsers },
    config = function(_, opts)
      local treesitter = require 'nvim-treesitter'
      treesitter.setup(opts)
      if vim.fn.executable 'tree-sitter' ~= 1 then
        vim.api.nvim_echo({
          {
            'tree-sitter CLI not found. Parsers cannot be installed.',
            'ErrorMsg',
          },
        }, true, {})
        return false
      end
      treesitter.install(opts.install)
    end,
  },

  ------- FORMATTER -------------------------------------------------------------------------------
  {
    'stevearc/conform.nvim',
    opts = {},
    config = function()
      require('conform').setup({
        formatters = aggregated_stuff.formatters,
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
