param ( [switch]$Force )

$ProgressPreference = 'SilentlyContinue'

$GitConfigInf = @"
[Setup]
Lang=default
Group=Git
NoIcons=0
SetupType=default
Components=gitlfs,assoc,assoc_sh,windowsterminal,scalar
Tasks=
EditorOption=VIM
CustomEditorPath=
DefaultBranchOption=main
PathOption=CmdTools
SSHOption=OpenSSH
TortoiseOption=false
CURLOption=WinSSL
CRLFOption=LFOnly
BashTerminalOption=MinTTY
GitPullBehaviorOption=Rebase
UseCredentialManager=Enabled
PerformanceTweaksFSCache=Enabled
EnableSymlinks=Disabled
EnablePseudoConsoleSupport=Disabled
EnableFSMonitor=Disabled
"@

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
    $arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
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

  $installDir = Join-Path "$PSScriptRoot" "installed\git"
  New-Item "$installDir" -Type Directory -Force | Out-Null
  $configFile = New-TemporaryFile
  Set-Content -Value $GitConfigInf -Path "$configFile"

  Write-Host '[bootstrap] installing Git for Windows'
  Start-Process -Wait -FilePath "$tmp" -ArgumentList @(
    '/SILENT',
    '/NORESTART', 
    '/CURRENTUSER',
    "/DIR=`"$installDir`"",
    "/LOADINF=`"$configFile`""
    '/COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"'
  )

  Remove-Item "$configFile" -Force
  Remove-Item "$tmp" -Force
}
