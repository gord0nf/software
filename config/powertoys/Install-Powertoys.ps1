param(
  [string]$InstallDir,
  [switch]$Force
)

$ProgressPreference = 'SilentlyContinue'

function Test-Installed() {
  $possiblePaths = "$env:ProgramFiles\PowerToys", "$env:LOCALAPPDATA\PowerToys" 
  foreach ($path in $possiblePaths) {
    if (Test-Path $path -PathType Container) {
      return $true
    }
  }
  return $false
}

function Get-VersionTag() {
  $releaseInfo = `
    Invoke-WebRequest -UseBasicParsing "https://api.github.com/repos/microsoft/PowerToys/releases/latest" `
    | ConvertFrom-Json
  return $releaseInfo.tag_name
}

function Get-DownloadUrl() {
  param ( [string]$ReleaseTag )
  $version = $ReleaseTag.Substring(1)
  $url = "https://github.com/microsoft/PowerToys/releases/download/$ReleaseTag/"
  if ($env:PROCESSOR_ARCHITECTURE -eq "Arm64") {
    $url += "PowerToysUserSetup-$version-arm64.exe"
  } else {
    $url += "PowerToysUserSetup-$version-x64.exe"
  }
  return $url
}

if (!$Force -and (Test-Installed)) {
  Write-Host "[powertoys] already installed"
} else {
  Write-Host "[powertoys] getting latest release tag"
  $tag = Get-VersionTag
  $url = Get-DownloadUrl $tag

  Write-Host "[powertoys] downloading"
  $installer = (New-TemporaryFile).FullName
  Move-Item "$installer" "$installer.exe"
  $installer += ".exe"
  Invoke-WebRequest -UseBasicParsing -OutFile "$installer" "$url"

  Write-Host "[powertoys] installing"
  Start-Process "$installer" -ArgumentList '/passive' -Wait
}
