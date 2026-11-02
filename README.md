# iCloud Passwords for Firefox on Windows

Apple's official **iCloud Passwords** extension for Firefox says *"The Passwords extension is not currently available on Firefox for Windows."* This tiny fix makes it work.

No modified extension, no Apple code, no admin rights. Two small files and one registry entry.

## Why it doesn't work out of the box

- iCloud for Windows already ships a Firefox native-messaging manifest for the extension, but registers it only inside its MSIX package's virtual registry. Firefox never sees it.
- The helper (`iCloudPasswordsExtensionHelper.exe`) lives in the protected `WindowsApps` folder, which other programs can't launch directly.
- Windows provides an *app execution alias* for it, but that's a special reparse point that Firefox can't start directly.

When the extension can't reach the helper, it shows the "not available" message.

## What this does

1. Writes a 2-line `host.bat` that launches the helper through its app execution alias (`cmd` can do that, Firefox can't).
2. Writes a native-messaging manifest pointing to that wrapper and allowing only Apple's extension ID (`password-manager-firefox-extension@apple.com`).
3. Registers it under `HKCU\Software\Mozilla\NativeMessagingHosts\com.apple.passwordmanager`, where Firefox looks.

Files go to `%LOCALAPPDATA%\iCloudPasswordsFirefox`.

## Requirements

- Windows 10/11
- [iCloud for Windows](https://apps.microsoft.com/detail/9PKTQ5699M62) from the Microsoft Store, signed in, with **Passwords** turned on
- Firefox with Apple's [iCloud Passwords extension](https://addons.mozilla.org/firefox/addon/icloud-passwords/) installed

## Install

1. Download or clone this repo.
2. Open PowerShell in the folder (a normal one, not as admin) and run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```
3. **Fully close Firefox** and open it again.
4. Click the iCloud Passwords icon and enter the 6-digit code shown by iCloud for Windows.

## Uninstall

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall.ps1
```

## Troubleshooting

| Problem | Fix |
|---|---|
| Still says "not available on Firefox for Windows" | Make sure Firefox was **fully** closed and reopened, including any background windows. |
| iCloud Passwords app shows "Windows cannot access the specified device, path, or file" | The iCloud install is broken. Reset it in **Settings → Apps → iCloud → Advanced options → Reset**, or run `Get-AppxPackage AppleInc.iCloud \| Reset-AppxPackage`. |
| iCloud says "Authentication failed. Retry will be attempted." | Quit iCloud from the tray and sign in again. Apple's sign-in can take a few tries. |
| Install script says the helper wasn't found | Open iCloud for Windows once, sign in and enable Passwords, then run the installer again. |

## Security

- Only Apple's own extension ID is allowed to talk to the helper.
- Nothing is downloaded; the scripts are short, so read them before running.
- Your passwords never pass through anything in this repo. The extension talks to Apple's helper exactly as it does in Chrome and Edge.

## Disclaimer

This is an unofficial community project. It is **not affiliated with, endorsed by, or supported by Apple Inc. or Mozilla**. iCloud, iCloud Passwords and Apple are trademarks of Apple Inc., registered in the U.S. and other countries. Firefox is a trademark of the Mozilla Foundation.

This repository contains **no Apple software or code**. It only creates a configuration file and a launcher script that point Firefox to software you've already installed from Apple. Use at your own risk; Apple may change or break this at any time.

Licensed under the [MIT License](LICENSE).
