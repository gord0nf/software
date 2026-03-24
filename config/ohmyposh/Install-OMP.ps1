# Modified install.ps1 script (https://ohmyposh.dev/docs/installation/windows#installation)
# to not use Add-AppxPackage. Also UseBasicParsing for webreqs

param(
  [string]$InstallDir
)

$ProgressPreference = "SilentlyContinue"

# --- INSTALLER START

$installer = ''
$arch = (Get-CimInstance -Class Win32_Processor -Property Architecture).Architecture | Select-Object -First 1
switch ($arch) {
    5 { $installer = "install-arm64.msix" } # ARM64
    9 {
        if ([Environment]::Is64BitOperatingSystem) {
            $installer = "install-x64.msix"
        }
        else {
            Write-Host "MSIX installer is only available for x64 and ARM64 architectures."
            exit
        }
    }
    12 { $installer = "install-arm64.msix" } # ARM64 Surface Pro X
    default {
        Write-Host "MSIX installer is only available for x64 and ARM64 architectures."
        exit
    }
}

Write-Host "Downloading $installer..."

# validate the availability of New-TemporaryFile
if (Get-Command -Name New-TemporaryFile -ErrorAction SilentlyContinue) {
    $tmp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'msix' } -PassThru
}
else {
    $tmp = New-Item -Path $env:TEMP -Name ([System.IO.Path]::GetRandomFileName() -replace '\.\w+$', '.msix') -Force -ItemType File
}
$url = "https://cdn.ohmyposh.dev/releases/latest/$installer"

# check if we can make https requests and download the binary
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing -Uri $url -Method Head | Where-Object -FilterScript { $_.StatusCode -ne 200 }  # Suppress success output
}
catch {
    Write-Host "Unable to download $installer. Please check your internet connection."
    exit
}

Invoke-WebRequest -UseBasicParsing -OutFile $tmp $url
Write-Host 'Installing package for current user...'

# Add-AppxPackage -Path $tmp

# --- INSTALLER END

Move-Item "$tmp" "$tmp.zip"
Expand-Archive "$tmp.zip" "$InstallDir"
