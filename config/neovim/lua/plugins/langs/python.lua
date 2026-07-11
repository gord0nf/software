return {
  servers = {
    pyright = {},
  },
  parsers = {
    'python',
    'ninja',
    'rst',
  },
  formatters_by_ft = {
    python = { 'black' },
  },
}
