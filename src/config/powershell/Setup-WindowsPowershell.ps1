Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Install modern PSReadLine
if ((Get-Module PSReadLine).Version -ne (Find-Module PSReadLine).Version) {
  Install-Module PSReadLine -Repository PSGallery -Scope CurrentUser -Force
}
