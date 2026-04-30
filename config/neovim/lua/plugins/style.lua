return {
  {
    'Mofiqul/vscode.nvim',
    config = function()
      vim.o.background = 'dark'

      local c = require('vscode.colors').get_colors()
      require('vscode').setup({
        transparent = true,
        italic_comments = true,
        italic_inlayhints = true,
        underline_links = true,
        disable_nvimtree_bg = true,
        terminal_colors = true,
        color_overrides = {
          vscLineNumber = '#FFFFFF',
        },
        group_overrides = {
          Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
        },
      })
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        globalstatus = true,
      },
      sections = {
        lualine_c = {
          {
            'filename',
            file_status = false,
            path = 1,
          },
        },
        lualine_x = {
          'import',
        },
        lualine_y = {
          {
            function()
              local lsps = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() })
              local icon = require('nvim-web-devicons').get_icon_by_filetype(
                vim.api.nvim_get_option_value('filetype', { buf = 0 })
              )
              if lsps and #lsps > 0 then
                local names = {}
                for _, lsp in ipairs(lsps) do
                  table.insert(names, lsp.name)
                end
                return string.format('%s %s', table.concat(names, ', '), icon)
              else
                return icon or ''
              end
            end,
            on_click = function()
              vim.api.nvim_command('LspInfo')
            end,
            color = function()
              local _, color = require('nvim-web-devicons').get_icon_cterm_color_by_filetype(
                vim.api.nvim_get_option_value('filetype', { buf = 0 })
              )
              return { fg = color }
            end,
          },
          'encoding',
          'progress',
        },
      },
    },
  },
}
