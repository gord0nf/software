param ( [switch]$Force )

$ProgressPreference = 'SilentlyContinue'

function Get-VersionTag() {
  $releaseInfo = `
    Invoke-WebRequest -UseBasicParsing "https://api.github.com/repos/git-for-windows/git/releases/latest" `
    | ConvertFrom-Json
  return $releaseInfo.tag_name
}

function Get-DownloadUrl($Version) {
  if ($Version -match "^v(\d+\.\d+\.\d+)\.windows.*$") {
    $versionNumber = $Matches[1]
    if ($Version -like '*.2') {
      $versionNumber += '.2'
    }
    switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) {
      "X64" { $arch = '64-bit' }
      "Arm64" { $arch = 'arm64' }
      default { 
        throw "OSArchitecture not supported"
        exit 1
      }
    }
    return "https://github.com/git-for-windows/git/releases/download/$Version/Git-$versionNumber-$arch.exe"
  } else {
    throw "Couldn't parse version number from tag"
    exit 1
  }
}

if (!$Force -and (Get-Command bash -ErrorAction SilentlyContinue)) {
  Write-Host '[bootstrap] bash is already installed'
} else {
  Write-Host '[bootstrap] get Git for Windows version'
  $version = Get-VersionTag
  $url = Get-DownloadUrl $version

  Write-Host '[bootstrap] downloading Git for Windows'
  $tmp = New-TemporaryFile
  Move-Item $tmp "$tmp.exe"
  $tmp = "$tmp.exe"
  Invoke-WebRequest -UseBasicParsing -OutFile "$tmp" "$url"

  Write-Host '[bootstrap] installing Git for Windows'
  $installDir = Join-Path (Split-Path -Parent "$PSScriptRoot") "installed\git"
  Start-Process -Wait -FilePath "$tmp" -ArgumentList @(
    '/SILENT',
    '/NORESTART', 
    '/CURRENTUSER',
    "/DIR=`"$installDir`"",
    "/LOADINF=`"$PSScriptRoot\git-for-windows.inf`""
    '/COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"'
  )
}
