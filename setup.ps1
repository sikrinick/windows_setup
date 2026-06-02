<#
.SYNOPSIS
    Prepare a used Windows 10/11 laptop for everyday usage.

.DESCRIPTION
    Single entry point that dispatches to one of the setup phases.
    Phase1 must be run before Phase2, with a restart in between.

    Composite phases:
      All      - Phase1, reboot, then automatically run Phase2 on next login. (default)
      Phase1   - Wi-Fi + Updates + Chrome + Office. Ends with a restart.
      Phase2   - Language pack, locale, and welcome-screen copy. Run after Phase1. Ends with a restart.

    Atomic phases (re-runs / debugging):
      Wifi     - Connect to the configured Wi-Fi.
      Updates  - Install Windows Updates via PSWindowsUpdate.
      Chrome   - Install Chrome and set as default browser.
      Office   - Install Office 2021 and activate if possible.
      Language - Install primary/secondary languages, set locale, copy to system accounts.

    Requires configuration.json next to this script (see README.md).

.PARAMETER Phase
    Which phase to run. Tab-completable.

.EXAMPLE
    .\setup.ps1
    Runs the full flow (default): Phase1, reboots, then Phase2 runs automatically on next login.

.EXAMPLE
    .\setup.ps1 -Phase Phase1
    Runs Phase1 only and reboots. Phase2 must be started manually.

.EXAMPLE
    .\setup.ps1 -Phase Phase2
    Runs Phase2 only: language and locale setup.

.EXAMPLE
    .\setup.ps1 -Phase Wifi
    Just connects to the configured Wi-Fi network.

.EXAMPLE
    Get-Help .\setup.ps1 -Full
    Show this help.
#>
[CmdletBinding()]
Param(
    [ValidateSet('All','Phase1','Phase2','Wifi','Updates','Chrome','Office','Language')]
    [string]$Phase = 'All'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

$logDir = Join-Path $PSScriptRoot 'logs'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$logPath = Join-Path $logDir ("setup-{0}-{1}.log" -f $Phase, (Get-Date -Format 'yyyyMMdd-HHmmss'))
Start-Transcript -Path $logPath | Out-Null

Trap {
  Write-Host "`nError: $_" -ForegroundColor Red
  Write-Host "Log: $logPath" -ForegroundColor Yellow
  Read-Host "Press Enter to exit"
  exit 1
}

Import-Module $PSScriptRoot\windows\administrator.psm1

if (Restart-AsAdminIfNeeded -ScriptPath $PSCommandPath -BoundParameters $PSBoundParameters) { Exit }

function Get-SetupConfiguration {
    Try {
        return Get-Content $PSScriptRoot\configuration.json | ConvertFrom-Json
    }
    Catch {
        Write-Error "configuration.json was not found. Please, check README.md for setup requirements"
        Read-Host "Press any key to exit"
        Exit
    }
}

function Invoke-WifiPhase {
    Import-Module $PSScriptRoot\wifi\setup.psm1
    $cfg = Get-SetupConfiguration
    Write-Output "Connecting to WiFi $($cfg.SSID)"
    Connect-Wifi -SSID $cfg.SSID -Password $cfg.Password
}

function Invoke-UpdatesPhase {
    Import-Module $PSScriptRoot\windows\update.psm1
    Update-Windows
}

function Invoke-ChromePhase {
    Import-Module $PSScriptRoot\apps\chrome\setup.psm1
    Write-Output "Installing Chrome"
    $proc = Install-Chrome
    $proc.WaitForExit()
    Write-Output "Chrome is installed"
    Set-ChromeAsDefault
}

function Invoke-OfficePhase {
    Import-Module $PSScriptRoot\apps\office2021\setup.psm1
    $cfg = Get-SetupConfiguration
    Write-Output "Installing Office 2021 Basic (Word, Excel, PowerPoint)"
    $proc = Install-Office2021 -LanguageCode $cfg.PrimaryLanguageCode
    $proc.WaitForExit()
    Write-Output "Office 2021 is installed"

    Copy-OfficeShortcutsToDesktop

    Try {
        Import-Module $PSScriptRoot\apps\office2021\activate.psm1
        Enable-Office2021
    }
    Catch {
        Write-Error "Failed to activate Office 2021."
    }
}

function Invoke-LanguagePhase {
    Import-Module $PSScriptRoot\language\setup.psm1
    $cfg = Get-SetupConfiguration
    Install-LocalesFromConfiguration `
        -PrimaryLanguageCode $cfg.PrimaryLanguageCode `
        -PrimaryInputCode $cfg.PrimaryInputCode `
        -SecondaryLanguages $cfg.SecondaryLanguages `
        -GeoId $cfg.GeoId `
        -TimeZone $cfg.TimeZone
}

function Invoke-Phase1Body {
    Invoke-WifiPhase
    Invoke-UpdatesPhase

    # Install Chrome and Office in parallel
    Import-Module $PSScriptRoot\apps\chrome\setup.psm1
    Import-Module $PSScriptRoot\apps\office2021\setup.psm1
    $cfg = Get-SetupConfiguration

    Write-Output "Installing Chrome"
    $chromeProc = Install-Chrome
    Write-Output "Installing Office 2021 Basic (Word, Excel, PowerPoint)"
    $officeProc = Install-Office2021 -LanguageCode $cfg.PrimaryLanguageCode

    $chromeProc.WaitForExit()
    Write-Output "Chrome is installed"
    Set-ChromeAsDefault

    $officeProc.WaitForExit()
    Write-Output "Office 2021 is installed"
    Copy-OfficeShortcutsToDesktop

    Try {
        Import-Module $PSScriptRoot\apps\office2021\activate.psm1
        Enable-Office2021
    }
    Catch {
        Write-Error "Failed to activate Office 2021."
    }
}

function Register-Phase2OnNextLogin {
    $cmd = "powershell.exe -ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`" -Phase Phase2"
    $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name 'WindowsSetupPhase2' -Value $cmd
    Write-Output "Phase2 registered to run on next login."
}

switch ($Phase) {
    'Wifi'     { Invoke-WifiPhase }
    'Updates'  { Invoke-UpdatesPhase }
    'Chrome'   { Invoke-ChromePhase }
    'Office'   { Invoke-OfficePhase }
    'Language' {
        Invoke-LanguagePhase
        Read-Host "Finished"
    }
    'Phase1' {
        Invoke-Phase1Body
        Restart-Computer
    }
    'Phase2' {
        Invoke-LanguagePhase
        Restart-Computer
    }
    'All' {
        Invoke-Phase1Body
        Register-Phase2OnNextLogin
        Restart-Computer
    }
}
