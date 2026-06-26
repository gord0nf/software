local settings_script = os.getenv('NVIM_SETTINGS')
Settings = (settings_script and dofile(settings_script)) or {}

require('config.options')
require('config.lazy')
require('config.mappings')
require('config.autocommands')
require('config.style')
require('custom.theme')
