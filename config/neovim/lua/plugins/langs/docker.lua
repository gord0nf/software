vim.filetype.add({
  filename = {
    ['docker-compose.yaml'] = 'yaml.docker-compose',
    ['docker-compose.yml'] = 'yaml.docker-compose',
    ['compose.yaml'] = 'yaml.docker-compose',
    ['compose.yml'] = 'yaml.docker-compose',
  },
  pattern = {
    ['compose.*%.ya?ml'] = 'yaml.docker-compose',
    ['docker%-compose.*%.ya?ml'] = 'yaml.docker-compose',
  },
})

return {
  servers = {
    dockerls = {},
    docker_compose_language_service = {},
  },

  parsers = { 'dockerfile', 'yaml' },

  formatters_by_ft = {
    dockerfile = { 'dockerfmt' },
  },
}
