function Setup {
    Param(
        [Parameter(Mandatory=$true)]
        [bool]$InstallLanguage
    )

    # Import dependencies
    Try {
        Import-Module $PSScriptRoot\install\activate.psm1
    }
    Catch {
        Write-Error "Failed to import module .\install\activate.psm1. Did you add implementation?"
    }

    # Import configuration
    Try {
        $Configuration = Get-Content $PSScriptRoot\configuration.json | ConvertFrom-Json
    }
    Catch {
        Write-Error "configuration.json was not found. Please, check README.md for setup requirements"
        Read-Host "Press Any Key to Exit"
        Exit
    }

    # Connect to Wi-Fi
    Import-Module $PSScriptRoot\wifi\setup.psm1
    Write-Output "Connecting to WiFi $($Configuration.SSID)"
    Setup-Wifi -SSID $Configuration.SSID -Password $Configuration.Password


    # Apps
    Import-Module $PSScriptRoot\apps\chrome\setup.psm1
    Import-Module $PSScriptRoot\apps\office2021\setup.psm1

    # Start installing Chrome
    Write-Output "Installing Chrome"
    $chromeInstallProcess = Install-Chrome

    # Start installing Office 2021
    Write-Output "Installing Office 2021 Basic (Word, Excel, PowerPoint)"
    $officeInstallProcess = Install-Office2021 -LanguageCode $Configuration.PrimaryLanguageCode

    # Wait for Chrome process
    $chromeInstallProcess.WaitForExit()
    Write-Output "Chrome is installed"

    Set-ChromeAsDefault

    # Wait for Office process
    $officeInstallProcess.WaitForExit()
    Write-Output "Office 2021 is installed"

    CopyOfficeShortcuts-ToDesktop

    # Try to activate products, if possible
    Try {
        Import-Module $PSScriptRoot\apps\office2021\activate.psm1
        Activate-Office2021
    }
    Catch {
        Write-Error "Failed to activate Office 2021."
    }


    if ($InstallLanguage) {
        Import-Module $PSScriptRoot\language\setup.psm1
    
        Install-LocalesFromConfiguration `
            -PrimaryLanguageCode $Configuration.PrimaryLanguageCode `
            -SecondaryLanguages $Configuration.SecondaryLanguages `
            -GeoId $Configuration.GeoId `
            -TimeZone $Configuration.TimeZone
    }
    Write-Output "All tasks completed."
    #Write-Output "Press any key to restart"
    Read-Host "Finished"
}