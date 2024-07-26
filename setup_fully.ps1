# Import dependencies
Import-Module $PSScriptRoot\windows\administrator.psm1
Import-Module $PSScriptRoot\setup.psm1

if (RestartAsAdministrator-IfNeeded) {
    Exit
}

Setup -InstallLanguage $true
