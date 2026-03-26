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
      contentProvider = { preferred = 'fernflower' }, -- Use fernflower to decompile library code ,
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
    },
    java_test = {},
    java_debug_adapter = {},
  },

  plugins = {
    { 'mfussenegger/nvim-jdtls' },
    -- { 'mfussenegger/nvim-dap' },
  },

  formatters_by_ft = {
    java = { 'google-java-format' },
  },
}
