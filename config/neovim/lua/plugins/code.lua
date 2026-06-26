local blink_keymap = {
  preset = 'none',
  ['<Tab>'] = { 'select_and_accept', 'fallback' },
  ['<S-Tab>'] = { 'show', 'hide', 'fallback' },
  ['<Up>'] = { 'select_prev', 'fallback' },
  ['<Down>'] = { 'select_next', 'fallback' },
  ['<C-p>'] = { 'select_prev', 'fallback' },
  ['<C-n>'] = { 'select_next', 'fallback' },
  ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
  ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
  ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  ['<C-u>'] = { 'scroll_signature_up', 'fallback' },
  ['<C-d>'] = { 'scroll_signature_down', 'fallback' },
}

local plugins = {
  {
    'saghen/blink.cmp',
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '*',
    ---@module 'blink.cmp'
    opts = {
      fuzzy = { implementation = 'lua' }, -- should be 'prefer_rust' but Windows doesn't like it...
      signature = { enabled = true },
      keymap = blink_keymap,
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'normal',
      },
      completion = {
        keyword = { range = 'full' },
        accept = {
          auto_brackets = {
            enabled = true,
            kind_resolution = {
              enabled = true,
              blocked_filetypes = { 'typescriptreact', 'javascriptreact', 'vue' },
            },
          },
        },
        list = { selection = { preselect = false } },
        menu = {
          auto_show = true,
          draw = {
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind' },
            },
            treesitter = { 'lsp' },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 300,
        },
        ghost_text = { enabled = true },
      },
      cmdline = {
        enabled = true,
        completion = {
          menu = { auto_show = true },
          ghost_text = { enabled = true },
        },
        keymap = blink_keymap,
      },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
    },
  },
  { 'tpope/vim-surround' },
}

if Settings.flash then
  table.insert(plugins, {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      jump = { inclusive = true },
      modes = {
        char = { jump_labels = true },
      },
    },
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
      },
      {
        'r',
        mode = 'o',
        function()
          require('flash').remote()
        end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter_search()
        end,
        desc = 'Treesitter Search',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  })
end

if Settings.tmux ~= false then
  table.insert(plugins, {
    'preservim/vimux',
    keys = {
      { '<leader>vp', '<cmd>VimuxPromptCommand<cr>', desc = 'Vimux prompt cmd' },
      { '<leader>vl', '<cmd>VimuxRunLastCommand<cr>', desc = 'Vimux run last' },
      { '<leader>vi', '<cmd>VimuxInspectRunner<cr>', desc = 'Vimux inspect runner' },
      { '<leader>vz', '<cmd>VimuxZoomRunner<cr>', desc = 'Vimux zoom runner' },
    },
  })
end

return plugins
