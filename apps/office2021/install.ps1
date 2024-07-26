# Import dependencies
Import-Module $PSScriptRoot\..\..\windows\administrator.psm1
Import-Module $PSScriptRoot\setup.psm1
Import-Module $PSScriptRoot\activate.psm1

if (RestartAsAdministrator-IfNeeded) {
    Exit
}

$Configuration = Get-Content $PSScriptRoot\..\..\configuration.json | ConvertFrom-Json

$officeInstallProcess = Install-Office2021 -LanguageCode $Configuration.PrimaryLanguageCode
$officeInstallProcess.WaitForExit()
Write-Output "Office 2021 is installed"

CopyOfficeShortcuts-ToDesktop

Activate-Office2021
