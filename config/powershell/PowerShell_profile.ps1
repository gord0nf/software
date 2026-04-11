function Test-Binary() {
    [OutputType([bool])]
    param ([string]$Binary)
    try {
        $cmd = Get-Command $Binary -ErrorAction SilentlyContinue
        return ($cmd -ne $null)
    }
    catch { return $false }
}

function Push-ToPath() {
    param(
      [string[]]$Directories,
      [switch]$AtStart
    )
    $ValidDirectories = $Directories | Where-Object { Test-Path $_ }
    if ($env:PATH[-1] -ne ';') {
        $env:PATH += ';'
    }
    if ($AtStart) {
      $env:PATH = "$($ValidDirectories -Join ';');$env:PATH"
    } else {
      $env:PATH += ($ValidDirectories -Join ';')
    }
}

function Set-EnvironmentVars() {
    param([hashtable]$EnvVariablePairs, [switch]$NotAPath)
    foreach ($name in $EnvVariablePairs.Keys) {
        $value = $EnvVariablePairs[$name]
        if (!$NotAPath -and (Test-Path $value -IsValid) -and !(Test-Path $value)) {
            continue
        }
        Set-Item -Path "Env:$name" -Value "$value"
    }
}

# Custom env variables ----------------------------------------------------------------------------

$PROFILE = $PSCommandPath

Set-EnvironmentVars @{
    SOFTWARE = "$HOME\dev\software"
    REPOS    = "$HOME\dev\repos"
    HIST     = (Get-PSReadLineOption).HistorySavePath
    SHELL    = (Get-Command powershell).Path
}

$HIST = $env:HIST
$SHELL = $env:SHELL

# PATH --------------------------------------------------------------------------------------------

# Register to path from software.csv

$SoftwareCsv = "$PSScriptRoot\..\..\software.csv"
if (Test-Path "$SoftwareCsv") {
  $paths = @()
   Import-Csv "$SoftwareCsv" | ForEach-Object {
     $paths += $_.paths -split '\|'
   }
   Push-ToPath $paths
}

# Software Paths 
Push-ToPath @(
    "C:\Windows\Microsoft.NET\Framework\v4.0.30319\",           # DOTNET C#
    "C:\desktopVS\VC\Tools\MSVC\14.44.35207\bin\Hostx86\x86\",  # MSVC C/C++
    "C:\eclipse",                                               # Eclipse IDE
    "$env:SOFTWARE",                    # Any generic software
    "$env:SOFTWARE\go\bin",             # GoLang
    "$env:SOFTWARE\sqlite",             # SQLite
    "$env:SOFTWARE\lazygit",            # Lazygit
    "$env:SOFTWARE\ripgrep",            # Ripgrep (for telescope, usually)
    "$env:SOFTWARE\msys2"               # MSYS2 / Mingw
    "$env:SOFTWARE\make\bin",		        # Gnu Make
    "$env:SOFTWARE\apache-maven\bin",   # Apache Maven
    "$env:SOFTWARE\gradle\bin",         # Gradle
    "$env:SOFTWARE\nodejs",             # NodeJS
    "$env:SOFTWARE\neovim\bin",		      # NeoVim
    "$env:SOFTWARE\sublime_merge",      # Sublime Merge
    "$env:SOFTWARE\github-cli\bin",     # GitHub cli
    "$env:SOFTWARE\ffmpeg\bin"          # FFmpeg
)

function Get-WebBrowserDirectories() {
    [OutputType([string[]])]
    param ()

    $PossibleBrowserLocations = @(
        @(
            { return (Get-ItemProperty 'HKLM:\SOFTWARE\Mozilla\Mozilla Firefox\*\Main').PathToExe },
            "$env:ProgramFiles\Mozilla Firefox\", "${env:ProgramFiles(x86)}\Mozilla Firefox\", "$env:LOCALAPPDATA\Mozilla Firefox\"
        ),
        @(
            { return (Get-ItemProperty 'HKLM:\SOFTWARE\Classes\ChromeHTML\shell\open\command')."(default)" -replace ' *--.*', '' },
            "$env:ProgramFiles\Google\Chrome\Application\", "${env:ProgramFiles(x86)}\Google\Chrome\Application\", "$env:LOCALAPPDATA\Google\Chrome\Application\"
        ),
        @(
            { return (Get-ItemProperty 'HKLM:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command')."(default)" -replace ' *--.*', '' },
            "$env:ProgramFiles\Microsoft\Edge\Application\", "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\", "$env:LOCALAPPDATA\Microsoft\Edge\Application\"
        )
    )

    $BrowserLocations = $PossibleBrowserLocations | ForEach-Object {
        foreach ($Location in $_) {
            if ($Location -is [scriptblock]) {
                try { $Location = $Location.Invoke() }
                catch { continue }
            }
            if ($Location -and ($Location.Length -gt 0) -and (Test-Path "$Location")) {
                return $Location
            }
        }
    }

    return $BrowserLocations
}
Push-ToPath (Get-WebBrowserDirectories)

# Custom functions and aliases -------------------------------------------------------------------- 	
	
function Get-AllChildItems() { Get-ChildItem -Force @args } 	
function Start-Explorer() { 
  param ( [string]$Path = '.' )
  Start-Process $Path
}
function Invoke-BasicWebRequest() { 
  $save = $ProgressPreference
  $ProgressPreference = 'SilentlyContinue' 
  Invoke-WebRequest -UseBasicParsing @args
  $ProgressPreference = $save
}
function Invoke-WebRequestToFile() {
  param ( [string]$Uri )
  Invoke-BasicWebRequest -Uri "$Uri" -O "$PWD\$([System.IO.Path]::GetFileName($Uri))" @args
}
function Get-DirectorySize() {
    param ( [string]$Path )
    return (Get-ChildItem -Path "$Path" -Recurse -File -Force | Measure-Object -Property Length -Sum).Sum
}
function New-Junction() {
    param ( [string]$Path, [string]$Junction )
    $Path = Resolve-Path "$Path"
    $Junction = [System.IO.Path]::GetFullPath((Join-Path $pwd.Path $Junction))
    cmd.exe /C "mklink /J ""$Junction"" ""$Path"""
}
function Expand-Msi() { 	
    param ( [string]$Path, [string]$Destination ) 	
    $msiFull = (Get-Item $Path).FullName 	
    $destFull = (Get-Item $Destination).FullName 	
    cmd.exe /c "msiexec /a ""$msiFull"" /qb TARGETDIR=""$destFull""" 	
} 	
function Expand-Cab() { 	
    param( [string]$Path, [string]$Destination ) 	
    expand.exe -F:* "$Path" "$Destination" 	
} 	
	
Set-Alias l Get-AllChildItems
Set-Alias e Start-Explorer
Set-Alias zip Compress-Archive 	
Set-Alias unzip Expand-Archive
Set-Alias ffox firefox
Set-Alias -Option AllScope curl Invoke-BasicWebRequest
Set-Alias -Option AllScope wget Invoke-WebRequestToFile

# Editors -----------------------------------------------------------------------------------------

$PreferredEditors = @("code", "nvim", "vim", "notepad++", "notepad", "vi")
foreach ($editor in $PreferredEditors) {
    if (Test-Binary $editor) {
        Set-EnvironmentVars @{ 
            EDITOR = $editor
        } -NotAPath
        break
    }
}
if ($env:EDITOR -like 'code*') {
    $env:EDITOR += " --wait"
}

# MSYS2/Mingw -------------------------------------------------------------------------------------

if (Test-Binary msys2) {
    Set-EnvironmentVars @{
        MSYS2_ROOT             = "$SOFTWARE\msys2" 
        OPENSSL_ROOT_DIR       = "$env:SOFTWARE\openssl"
        OPENSSL_CRYPTO_LIBRARY = "$env:SOFTWARE\openssl\libcrypto.a"
        OPENSSL_INCLUDE_DIR    = "$env:SOFTWARE\openssl\include"
    }
}

# Java JDK ----------------------------------------------------------------------------------------

function Test-JavaHome() {
  param ( [string]$Dir )
  $NotFoundDirs = "bin", "lib", "include" | Where-Object { !(Test-Path $(Join-Path "$Dir" "$_") -PathType Container) }
  if ($NotFoundDirs.Length -gt 0) {
    return $false
  }
  return Test-Path $(Join-Path "$Dir" "release") -PathType Leaf
}

if (Test-Binary java) {
  $JavaHome = Resolve-Path "$(Split-Path -Parent (Get-Command java).Path)\.."
  if (Test-JavaHome $JavaHome) {
    Set-EnvironmentVars @{
      JAVA_HOME = "$JavaHome"
    }
  }
}

# Cool command prompt -----------------------------------------------------------------------------

if (Test-Binary oh-my-posh) {
	$OMPConfig = "$PSScriptRoot\..\ohmyposh\config.json"
	if (!(Test-Path "$OMPConfig")) { $OMPConfig = 'takuya' }
	oh-my-posh init pwsh --config "$OMPConfig" | Invoke-Expression
}

# Check dll dependencies fast ---------------------------------------------------------------------

function Get-MissingDllDeps {
  param ( [string[]]$dlls)
  $dlls | ForEach-Object { 
    cmd /c "dumpbin -dependents $(Split-Path -Leaf $_)" | 
      Where-Object { $_.Contains(".dll") -and ! $_.Contains("Dump of file") } |
      ForEach-Object { $_.Trim() } 
  } |
    Select-Object -Unique |
    Where-Object { !(Test-Path $_) -and !(Get-Command -ErrorAction SilentlyContinue $_) }
}
