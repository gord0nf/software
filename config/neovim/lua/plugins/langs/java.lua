local utils = require('utils')

-- Load java runtimes for software installation, if available
local runtimes = {}
local java_install_dir =
  vim.fn.resolve(vim.fs.joinpath(vim.loop.fs_realpath(vim.fn.stdpath('config')), '../../installed/java/'))
if java_install_dir and vim.fn.isdirectory(java_install_dir) ~= 0 then
  local subdirs = utils.list_subdirs(java_install_dir)

  local default_version = 0
  local default_subdir = ''
  for _, subdir in ipairs(subdirs) do
    local version = tonumber(subdir:match('%d+'))
    if version and version > default_version then
      default_subdir = subdir
      default_version = version
    end

    runtimes[#runtimes + 1] = {
      name = 'JavaSE-' .. version,
      path = vim.fs.joinpath(java_install_dir, subdir),
    }
  end

  local idx = utils.index_of(subdirs, default_subdir)
  if idx ~= -1 then
    runtimes[idx].default = true
  end
end

return {
  parsers = { 'java' },

  servers = {
    jdtls = {
      settings = {
        java = {
          configuration = {
            runtimes = runtimes,
          },
        },
      },
    },
    java_test = {},
    java_debug_adapter = {},
  },

  plugins = {
    {
      {
        -- based on https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/java.lua
        'mfussenegger/nvim-jdtls',
        dependencies = { 'folke/which-key.nvim' },
        ft = { 'java' },
        opts = function()
          local cmd = { vim.fn.exepath('jdtls') }
          local lombok_jar = vim.fn.expand('$MASON/share/jdtls/lombok.jar')
          table.insert(cmd, string.format('--jvm-arg=-javaagent:%s', lombok_jar))

          return {
            root_dir = function(path)
              return vim.fs.root(path, vim.lsp.config.jdtls.root_markers)
            end,
            project_name = function(root_dir)
              return root_dir and vim.fs.basename(root_dir)
            end,
            jdtls_config_dir = function(project_name)
              return vim.fn.stdpath('cache') .. '/jdtls/' .. project_name .. '/config'
            end,
            jdtls_workspace_dir = function(project_name)
              return vim.fn.stdpath('cache') .. '/jdtls/' .. project_name .. '/workspace'
            end,
            cmd = cmd,
            full_cmd = function(opts)
              local fname = vim.api.nvim_buf_get_name(0)
              local root_dir = opts.root_dir(fname)
              local project_name = opts.project_name(root_dir)
              cmd = vim.deepcopy(opts.cmd)
              if project_name then
                vim.list_extend(cmd, {
                  '-configuration',
                  opts.jdtls_config_dir(project_name),
                  '-data',
                  opts.jdtls_workspace_dir(project_name),
                })
              end
              return cmd
            end,

            dap = { hotcodereplace = 'auto', config_overrides = {} },
            dap_main = {},
            test = true,
            settings = {
              java = {
                inlayHints = {
                  parameterNames = {
                    enabled = 'all',
                  },
                },
              },
            },
          }
        end,
        config = function(_, opts)
          local bundles = {} ---@type string[]
          local mason_registry = require('mason-registry')
          if opts.dap and mason_registry.is_installed('java-debug-adapter') then
            bundles = vim.fn.glob('$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin-*jar', false, true)
            if opts.test and mason_registry.is_installed('java-test') then
              vim.list_extend(bundles, vim.fn.glob('$MASON/share/java-test/*.jar', false, true))
            end
          end
          local function attach_jdtls()
            local fname = vim.api.nvim_buf_get_name(0)

            local config = utils.extend_or_override({
              cmd = opts.full_cmd(opts),
              root_dir = opts.root_dir(fname),
              init_options = { bundles = bundles },
              settings = opts.settings,
              capabilities = require('blink.cmp').get_lsp_capabilities(),
            }, opts.jdtls)

            require('jdtls').start_or_attach(config)
          end

          vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'java' },
            callback = attach_jdtls,
          })

          vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.name == 'jdtls' then
                local wk = require('which-key')
                wk.add({
                  {
                    mode = 'n',
                    buffer = args.buf,
                    { '<leader>cx', group = 'extract' },
                    { '<leader>cxv', require('jdtls').extract_variable_all, desc = 'Extract Variable' },
                    { '<leader>cxc', require('jdtls').extract_constant, desc = 'Extract Constant' },
                    { '<leader>cgs', require('jdtls').super_implementation, desc = 'Goto Super' },
                    { '<leader>cgS', require('jdtls.tests').goto_subjects, desc = 'Goto Subjects' },
                    { '<leader>co', require('jdtls').organize_imports, desc = 'Organize Imports' },
                  },
                })
                wk.add({
                  {
                    mode = 'x',
                    buffer = args.buf,
                    { '<leader>cx', group = 'extract' },
                    {
                      '<leader>cxm',
                      [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                      desc = 'Extract Method',
                    },
                    {
                      '<leader>cxv',
                      [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                      desc = 'Extract Variable',
                    },
                    {
                      '<leader>cxc',
                      [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                      desc = 'Extract Constant',
                    },
                  },
                })

                mason_registry = require('mason-registry')
                if opts.dap and mason_registry.is_installed('java-debug-adapter') then
                  -- custom init for Java debugger
                  require('jdtls').setup_dap(opts.dap)
                  if opts.dap_main then
                    require('jdtls.dap').setup_dap_main_class_configs(opts.dap_main)
                  end

                  -- Java Test require Java debugger to work
                  if opts.test and mason_registry.is_installed('java-test') then
                    wk.add({
                      {
                        mode = 'n',
                        buffer = args.buf,
                        { '<leader>t', group = 'test' },
                        {
                          '<leader>tt',
                          function()
                            require('jdtls.dap').test_class({
                              config_overrides = type(opts.test) ~= 'boolean' and opts.test.config_overrides or nil,
                            })
                          end,
                          desc = 'Run All Test',
                        },
                        {
                          '<leader>tr',
                          function()
                            require('jdtls.dap').test_nearest_method({
                              config_overrides = type(opts.test) ~= 'boolean' and opts.test.config_overrides or nil,
                            })
                          end,
                          desc = 'Run Nearest Test',
                        },
                        { '<leader>tT', require('jdtls.dap').pick_test, desc = 'Run Test' },
                      },
                    })
                  end
                end

                if opts.on_attach then
                  opts.on_attach(args)
                end
              end
            end,
          })

          -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
          attach_jdtls()
        end,
      },
    },
    -- { 'mfussenegger/nvim-dap' },
  },

  formatters_by_ft = {
    java = { 'google-java-format' },
  },
}
