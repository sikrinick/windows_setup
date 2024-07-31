# Import dependencies
Import-Module $PSScriptRoot\windows\administrator.psm1
Import-Module $PSScriptRoot\wifi\setup.psm1
Import-Module $PSScriptRoot\apps\chrome\setup.psm1
Import-Module $PSScriptRoot\apps\office2021\setup.psm1
Import-Module $PSScriptRoot\windows\update.psm1

if (RestartAsAdministrator-IfNeeded) {
    Exit
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
Write-Output "Connecting to WiFi $($Configuration.SSID)"
Setup-Wifi -SSID $Configuration.SSID -Password $Configuration.Password

# Update Windows
Update-Windows

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

Restart-Computer