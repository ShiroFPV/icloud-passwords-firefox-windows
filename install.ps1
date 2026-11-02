# Connects Apple's official iCloud Passwords Firefox extension to iCloud for Windows.
# No admin rights needed: everything goes into the current user's profile.
$ErrorActionPreference = 'Stop'

$hostName = 'com.apple.passwordmanager'
$alias    = "$env:LOCALAPPDATA\Microsoft\WindowsApps\iCloudPasswordsExtensionHelper.exe"
$dir      = "$env:LOCALAPPDATA\iCloudPasswordsFirefox"
$regKey   = "HKCU:\Software\Mozilla\NativeMessagingHosts\$hostName"

if (-not (Get-AppxPackage AppleInc.iCloud)) {
    Write-Host 'iCloud for Windows is not installed. Get it from the Microsoft Store first:' -ForegroundColor Red
    Write-Host '  https://apps.microsoft.com/detail/9PKTQ5699M62'
    exit 1
}
if (-not (Test-Path $alias)) {
    Write-Host "iCloud's password helper was not found at $alias" -ForegroundColor Red
    Write-Host 'Open iCloud for Windows once, sign in, enable Passwords, then run this again.'
    exit 1
}

New-Item -ItemType Directory -Force $dir | Out-Null

# Firefox can't launch the app execution alias directly (it's a reparse point, not a real exe),
# but cmd can, so Firefox starts this wrapper instead.
[IO.File]::WriteAllText("$dir\host.bat", "@echo off`r`n`"%LOCALAPPDATA%\Microsoft\WindowsApps\iCloudPasswordsExtensionHelper.exe`" %*`r`n")

$manifest = [ordered]@{
    name               = $hostName
    description        = 'Apple iCloud Firefox Password Manager Host App'
    path               = "$dir\host.bat"
    type               = 'stdio'
    allowed_extensions = @('password-manager-firefox-extension@apple.com')
}
[IO.File]::WriteAllText("$dir\$hostName.json", ($manifest | ConvertTo-Json))

New-Item $regKey -Force | Out-Null
Set-ItemProperty $regKey '(default)' "$dir\$hostName.json"

Write-Host 'Installed.' -ForegroundColor Green
Write-Host 'Restart Firefox completely, then click the iCloud Passwords extension icon.'
