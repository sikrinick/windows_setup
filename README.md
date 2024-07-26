# Windows

A bunch of Powershell scripts to prepare used laptops with preinstalled Windows 10 21H2 for everyday usage.

## What it does
- Connect to WiFi
- Install Chrome
- Install Office 2021 Basic (Word, Excel, PowerPoint) with language set in configuration
- Activate Office 2021, if support is added
- Install language pack for primary language
- Install secondary languages
- Set primary language
- Set default timezone
- Set default region

## Future plans
- Add support for `Copy internation settings to the welcome screen, system accounts and new user accounts` for Windows 10
- Add support for Windows 11

## Requirements
* Windows 10 21H2+ (I didn't test on earlier versions. Didn't test on Windows 11)

## Setup

Firstly, you have to create file `configuration.json`, you can check example below.  
In this example `GeoId` is set to `Ukraine` and `TimeZone` is set to `Kyiv`.
```json
{
    "SSID": "YOUR_SSID",
    "Password": "Y0UrP@SsWord!",
    
    "PrimaryLanguageCode": "uk-UA",
    "SecondaryLanguages": ["en-US"],
    
    "GeoId": 241, 
    "TimeZone": "FLE Standard Time"
}
```

You can find GeoId value for your country [here (decimal values)](https://learn.microsoft.com/en-us/windows/win32/intl/table-of-geographical-locations).  
TimeZones can be found [here (column Timezone)](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones?view=windows-11).

## Activation

This is a secret sauce. If you want to automate it, you have to create `install/activate.psm1` Powershell module with next content:
```powershell
function Activate-Office2021 {
    # Put your code to activate Office 2021
}
```

## Run
Run `setup_fully.ps1` via Powershell or Right-click -> Run