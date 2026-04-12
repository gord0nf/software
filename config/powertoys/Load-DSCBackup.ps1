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
$backup = Get-Content "$Path" | ConvertFrom-Json

foreach ($module in $backup.Keys) {
  $config = $backup[$module] | ConvertTo-Json
  & "$PowerToysDSC" set --resource 'settings' --module $module --input "$config"
}
