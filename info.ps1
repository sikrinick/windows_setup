Import-Module $PSScriptRoot\windows\administrator.psm1
Import-Module $PSScriptRoot\windows\hardware.psm1

if (RestartAsAdministrator-IfNeeded) {
    Exit
}

Print-ComputerInfo

Read-Host "Press any key to exit"
Exit