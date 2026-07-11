return {
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, desc, opts)
            opts = opts or {}
            opts.desc = desc
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              gitsigns.nav_hunk('next')
            end
          end)
          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              gitsigns.nav_hunk('prev')
            end
          end)
          map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)

          -- Stage/reset
          map('n', '<leader>ghs', gitsigns.stage_hunk, 'toggle stage hunk')
          map('v', '<leader>gs', function()
            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, 'toggle stage hunk')
          map('n', '<leader>ghr', gitsigns.reset_hunk, 'reset hunk')
          map('v', '<leader>gr', function()
            gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          end, 'reset hunk')
          map('n', '<leader>gS', gitsigns.stage_buffer, 'stage buffer')
          map('n', '<leader>gR', gitsigns.reset_buffer, 'reset buffer')

          -- Diff
          map('n', '<leader>gd', gitsigns.diffthis, 'git diff staged')
          map('n', '<leader>gD', function()
            gitsigns.diffthis('~')
          end, 'git diff against previous commit')

          -- Toggles
          map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, 'toggle inline blame')
          map('n', '<leader>gtw', gitsigns.toggle_word_diff, 'toggle word diff')

          -- misc
          map('n', '<leader>ghp', gitsigns.preview_hunk, 'preview hunk')
          map('n', '<leader>ghi', gitsigns.preview_hunk_inline, 'preview hunk inline')
          map('n', '<leader>gB', function()
            gitsigns.blame_line({ full = true })
          end, 'Blame line')
          map('n', '<leader>hQ', function()
            gitsigns.setqflist('all')
          end)
          map('n', '<leader>hq', gitsigns.setqflist)
        end,
      }
    end,
  },
}
