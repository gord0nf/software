local function previous_buf_in_tab()
  local prev_buf = vim.fn.bufnr('#')
  return vim.api.nvim_buf_is_valid(prev_buf) and prev_buf > 0
end

return {
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    opts = {
      defaults = {
        layout_strategy = 'horizontal',
        layout_config = {
          horizontal = {
            prompt_position = 'top',
            width = { padding = 0 },
            height = { padding = 0 },
            preview_width = 0.5,
          },
        },
        sorting_strategy = 'ascending',
      },
    },
    keys = {
      { '<leader> ', '<cmd>Telescope find_files<cr>', desc = 'Telescope find files' },
      { '<leader>/', '<cmd>Telescope live_grep<cr>', desc = 'Telescope live grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Telescope buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Telescope help tags' },
      {
        '<leader>fc',
        function()
          require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })
        end,
        desc = 'Telescope find config files',
      },
    },
  },
  {
    'nvim-mini/mini.files',
    version = '*',
    config = function()
      require('mini.files').setup({
        options = { use_as_default_explorer = true },
        mappings = {
          close = '<Esc>',
          reset = '<BS>',
          synchronize = '<CR>',
          go_in_plus = 'n',
        },
      })
      local augroup = vim.api.nvim_create_augroup('mini_files_custom', { clear = true })

      -- Go in plus... in new tab
      vim.api.nvim_create_autocmd('FileType', {
        group = augroup,
        pattern = 'MiniFiles',
        callback = function(args)
          local buf_id = args.buf
          vim.keymap.set('n', 'L', function()
            MiniFiles.go_in({ close_on_file = true })
            -- TODO: super slapdash and buggy
            if previous_buf_in_tab() then
              vim.api.nvim_command('-tabnew #')
              vim.api.nvim_command('tabnext')
            end
          end, { buffer = buf_id, desc = 'Go in plus (new tab)' })
        end,
      })
    end,
    keys = {
      {
        '<leader>e',
        function()
          MiniFiles.open()
        end,
        desc = 'MiniFiles open',
      },
    },
  },
}
