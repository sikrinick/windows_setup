# Run as Administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit 
}

# Import dependencies
Import-Module $PSScriptRoot\wifi\setup.psm1
Import-Module $PSScriptRoot\install\install.psm1
Import-Module $PSScriptRoot\language\setup.psm1

# Import configuration
Try {
    $Configuration = Get-Content $PSScriptRoot\configuration.json | ConvertFrom-Json
}
Catch {
    Write-Error "configuration.json was not found. Please, check README.md for setup requirements"
    Read-Host "Press Any Key to Exit"
    Exit
}

Write-Output "Connecting to WiFi $($Configuration.SSID)"
Setup-Wifi -SSID $Configuration.SSID -Password $Configuration.Password

Write-Output "Installing Chrome"
$chromeInstallProcess = Install-Chrome

Write-Output "Installing Office 2021 Basic (Word, Excel, PowerPoint)"
$officeInstallProcess = Install-Office2021 -LanguageCode $Configuration.PrimaryLanguageCode

# Wait for all install processes
$chromeInstallProcess.WaitForExit()
Write-Output "Chrome is installed"
$officeInstallProcess.WaitForExit()
Write-Output "Office 2021 is installed"

# Post-install
# Copy shortcuts from start menu to desktop 
Copy-Item `
    -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk" `
    -Destination $env:Public\Desktop\ `
    -Force

Copy-Item `
    -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk" `
    -Destination $env:Public\Desktop\ `
    -Force

Copy-Item `
    -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\PowerPoint.lnk" `
    -Destination $env:Public\Desktop\ `
    -Force


# Try to activate products, if possible
Try {
    Import-Module $PSScriptRoot\install\activate.psm1
    Activate-Office2021
}
Catch {
    Write-Error "Failed to import module .\install\activate.psm1. Did you add implementation?"
}

# Install languages
Install-PrimaryLanguage -LanguageCode $Configuration.PrimaryLanguageCode
foreach ($LanguageCode in $Configuration.SecondaryLanguages) {
    Install-SecondaryLanguage -LanguageCode $LanguageCode
}

# Set primary locale
Set-PrimaryLocale `
    -LanguageCode $Configuration.PrimaryLanguageCode `
    -GeoId $Configuration.PrimaryGeoId `
    -TimeZone $Configuration.PrimaryTimeZone

# Remove not used languages
$LanguagesToKeep = @($Configuration.PrimaryLanguageCode) + $Configuration.SecondaryLanguages
Remove-OtherLanguages -LanguagesToKeep $LanguagesToKeep

Write-Output "All tasks completed."
Write-Output "Restarting the computer to apply all changes."

#Restart-Computer -Force
Read-Host "Finished"
Start-Process ms-settings:regionlanguage
Exit