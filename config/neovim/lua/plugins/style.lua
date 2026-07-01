local plugins = {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        globalstatus = Settings.theme == 'vscode' or Settings.theme == 'shado',
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'diff' },
        lualine_c = {
          {
            function()
              local reg = vim.fn.reg_recording()
              if reg ~= '' then
                return 'Recording @' .. reg
              end
              return ''
            end,
            color = { bg = 'black', fg = 'white', gui = 'bold' },
          },
          {
            'filename',
            file_status = true,
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
    init = function()
      vim.opt.cmdheight = 0
      vim.opt.showmode = false
    end,
  },
  { 'brenoprata10/nvim-highlight-colors' },
  {
    'saghen/blink.cmp',
    opts = function(_, opts)
      vim.tbl_deep_extend('force', opts, {
        completion = {
          menu = {
            draw = {
              components = {
                -- customize the drawing of kind icons
                kind_icon = {
                  text = function(ctx)
                    -- default kind icon
                    local icon = ctx.kind_icon
                    -- if LSP source, check for color derived from documentation
                    if ctx.item.source_name == 'LSP' then
                      local color_item =
                        require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                      if color_item and color_item.abbr ~= '' then
                        icon = color_item.abbr
                      end
                    end
                    return icon .. ctx.icon_gap
                  end,
                  highlight = function(ctx)
                    -- default highlight group
                    local highlight = 'BlinkCmpKind' .. ctx.kind
                    -- if LSP source, check for color derived from documentation
                    if ctx.item.source_name == 'LSP' then
                      local color_item =
                        require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                      if color_item and color_item.abbr_hl_group then
                        highlight = color_item.abbr_hl_group
                      end
                    end
                    return highlight
                  end,
                },
              },
            },
          },
        },
      })
    end,
  },
}

if Settings.theme then
  if Settings.theme == 'vscode' then
    table.insert(plugins, {
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
          color_overrides = {
            vscLineNumber = '#FFFFFF',
          },
          group_overrides = {
            Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
          },
        })
      end,
    })
  elseif Settings.theme == 'shado' then
    table.insert(plugins, { 'Shadorain/shadotheme' })
    table.insert(plugins, { 'xiyaowong/nvim-transparent', lazy = false })
  elseif Settings.theme:find('github', 1, true) == 1 then
    table.insert(plugins, {
      'projekt0n/github-nvim-theme',
      name = 'github-theme',
      opts = {
        options = {
          transparent = true,
          styles = {
            comments = 'italic',
            keywords = 'bold',
            types = 'italic,bold',
          },
        },
      },
    })
  end
end

return plugins
