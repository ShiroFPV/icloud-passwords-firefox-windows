# Removes everything install.ps1 created.
Remove-Item 'HKCU:\Software\Mozilla\NativeMessagingHosts\com.apple.passwordmanager' -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\iCloudPasswordsFirefox" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'Uninstalled. Restart Firefox.' -ForegroundColor Green
