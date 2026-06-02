# Windows Setup scripts

A bunch of Powershell scripts to prepare used laptops with preinstalled Windows 10 21H2 or Windows 11 for everyday usage.

## Purpose

I prepare laptops for Ukrainian soldiers or refugees occasionally, and those are utility scripts to automate this process.

## Requirements

- Windows 10 21H2+ or Windows 11

## Preparations

Firstly, you have to create file `configuration.json`, you can check example below.  
In this example `GeoId` is set to `Ukraine`, `TimeZone` is set to `Kyiv`, and default welcome screen and new user input is set to `Ukrainian (Extended)`.
```json
{
    "SSID": "YOUR_SSID",
    "Password": "Y0UrP@SsWord!",
    
    "PrimaryLanguageCode": "uk-UA",
    "SecondaryLanguages": ["en-US"],
    
    "GeoId": 241, 
    "TimeZone": "FLE Standard Time",

    "PrimaryInputCode": "0422:00020422"
}
```

You can find `GeoId` value for your country [here (decimal values)](https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations).  
`TimeZone` can be found [here (column Timezone)](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones?view=windows-11).

### Activation scripts

This is a secret sauce. If you want to automate it, you have to create `apps/office2021/activate.psm1` Powershell module with next content:
```powershell
function Enable-Office2021 {
    # Put your code to activate Office 2021
}
```

## Usage

All actions go through `setup.ps1`. Run `Get-Help .\setup.ps1 -Full` (or `.\setup.ps1 -?`) for full help.
The `-Phase` parameter is tab-completable.

- Run `.\setup.ps1` (defaults to `-Phase All`)
- Phase1 runs (Wi-Fi, updates, Chrome, Office — ~8 minutes)
- Laptop reboots
- On next login, Phase2 (language and locale) starts automatically via `RunOnce`
- Phase2 copies international settings to the Welcome screen and new user accounts, then reboots

> Phase2 launches from the path the script was first invoked from. Keep the USB drive plugged in across the reboot.

### Re-running a single step
Atomic phases are available for debugging or partial re-runs:
- `.\setup.ps1 -Phase Wifi`
- `.\setup.ps1 -Phase Updates`
- `.\setup.ps1 -Phase Chrome`
- `.\setup.ps1 -Phase Office`
- `.\setup.ps1 -Phase Language`

`.\setup.ps1 -Phase Phase1` runs Phase1 only (no auto-resume); `.\setup.ps1 -Phase Phase2` runs Phase2 only.

## What phases do

### All (default)
- Runs `Phase1`
- Registers `Phase2` in `HKLM\…\RunOnce` so it fires for the next user login after reboot
- Reboots

### Phase1
- Import `configuration.json`
- Connect to Wi-Fi
- Wait for internet availability
- Install Windows Updates, if possible
- Install Chrome (in parallel with Office)
- Install Office 2021 Basic (Word, Excel, PowerPoint) with language set in configuration
- Activate Office 2021, if possible
- Restart to install updates

### Phase2
- Install language pack for primary language
- Install secondary languages
- Remove other languages
- Set default timezone
- Set default region
- Copy international settings to the Welcome screen and new user accounts
- Restart

