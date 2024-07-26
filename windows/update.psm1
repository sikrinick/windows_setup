function Update-Windows {
    Install-Module -Name PSWindowsUpdate
    Import-Module PSWindowsUpdate
    Install-WindowsUpdate
}
