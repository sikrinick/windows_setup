# Restart original script as administrator if needed
# Returns True if started
function Restart-AsAdminIfNeeded {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        [System.Collections.IDictionary]$BoundParameters = @{}
    )
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$ScriptPath`"")
        foreach ($key in $BoundParameters.Keys) {
            $value = $BoundParameters[$key]
            if ($value -is [switch]) {
                if ($value.IsPresent) { $argList += "-$key" }
            } else {
                $argList += "-$key"
                $argList += "`"$value`""
            }
        }
        Start-Process powershell.exe -ArgumentList $argList -Verb RunAs
        return $true
    } else {
        return $false
    }
}
