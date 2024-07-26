# Restart original script as administrator if needed
# Returns True if started
function RestartAsAdministrator-IfNeeded {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
        $OriginalCaller = ((Get-PSCallStack).InvocationInfo.PSCommandPath -ne $null)[0]
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$OriginalCaller`"" -Verb RunAs
        return $true
    } else {
        return $false
    }
}
