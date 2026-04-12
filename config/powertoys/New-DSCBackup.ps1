param (
  [string]$Path
)

function Get-DSC() {
  $possiblePaths = "$env:ProgramFiles\PowerToys", "$env:LOCALAPPDATA\PowerToys"
  foreach ($path in $possiblePaths) {
    if (Test-Path $path -PathType Container) {
      return Join-Path $path "PowerToys.DSC.exe"
    }
  }
  throw "No PowerToys installation"
  exit 1
}

$PowerToysDSC = Get-DSC
$modules = & "$PowerToysDSC" modules --resource 'settings'

$backup = @{}
foreach ($module in $modules) {
  $config = & "$PowerToysDSC" export --resource 'settings' --module $module | ConvertFrom-Json
  $backup[$module] = $config
}

$backup | ConvertTo-Json | Out-File "$Path"
