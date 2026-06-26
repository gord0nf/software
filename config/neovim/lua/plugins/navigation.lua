local plugins = {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      winopts = { fullscreen = true },
      keymap = {
        builtin = {
          ['<C-j>'] = 'preview-down',
          ['<C-k>'] = 'preview-up',
          ['<C-S-j>'] = 'preview-page-down',
          ['<C-S-k>'] = 'preview-page-up',
          ['<C-l>'] = 'toggle-preview-wrap',
          ['<C-space>'] = 'toggle-preview',
        },
      },
    },
    keys = {
      { '<leader> ', '<cmd>FzfLua global<cr>', desc = 'Fzf global' },
      { '<leader>/', '<cmd>FzfLua live_grep<cr>', desc = 'Fzf live grep' },
      { '<leader>F', '<cmd>FzfLua resume<cr>', desc = 'Fzf resume' },
      { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Fzf find files' },
      {
        '<leader>fc',
        function()
          require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })
        end,
        desc = 'Fzf find config files',
      },
      {
        '<leader>fs',
        function()
          require('fzf-lua').files({ cwd = vim.fn.getenv('SOFTWARE') })
        end,
        desc = 'Fzf find software files',
      },
      { '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Fzf find buffers' },
      { '<leader>fr', '<cmd>FzfLua lsp_references<cr>', desc = 'Fzf find lsp_references' },
      { '<leader>fd', '<cmd>FzfLua lsp_definitions<cr>', desc = 'Fzf find lsp_definitions' },
      { '<leader>gs', '<cmd>FzfLua git_status<cr>', desc = 'Fzf git status' },
      { '<leader>gb', '<cmd>FzfLua git_blame<cr>', desc = 'Fzf git blame' },
      { '<leader>gc', '<cmd>FzfLua git_commits<cr>', desc = 'Fzf git commits' },
      { '<leader>z', '<cmd>FzfLua spellcheck<cr>', desc = 'Fzf git commits' },
      { '<leader>xx', '<cmd>FzfLua diagnostics_workspace<cr>', desc = 'Fzf git commits' },
      { '<leader>xb', '<cmd>FzfLua diagnostics_document<cr>', desc = 'Fzf git commits' },
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
          go_in_plus = 'L',
        },
      })
    end,
    keys = {
      {
        '<leader>e',
        function()
          require('mini.files').open()
        end,
        desc = 'MiniFiles open',
      },
    },
  },
}

if Settings.tmux ~= false then
  table.insert(plugins, {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
      'TmuxNavigatorProcessList',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  })
else
  vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
  vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to bottom window' })
  vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to top window' })
  vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })
end

return plugins
