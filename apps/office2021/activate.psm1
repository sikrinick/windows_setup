function Activate-Office2021 {

    Write-Output "Activating Office 2021"

    ## Set working directory to one with Office Software Protection Platform
    $osppPathX64 = "C:\Program Files\Microsoft Office\Office16\ospp.vbs"
    $osppPathX86 = "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs"

    if (Test-Path -Path $osppPathX64) {
        Push-Location -Path "C:\Program Files\Microsoft Office\Office16"
    } elseif (Test-Path -Path $osppPathX86) {
        Push-Location -Path "C:\Program Files (x86)\Microsoft Office\Office16"
    }

    ## Install Office 2021 volume license
    $licenses = Get-ChildItem -Path "..\root\Licenses16\ProPlus2021VL_KMS*.xrm-ms"
    foreach ($license in $licenses) {
        Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /inslic:`"$($license.FullName)`"" -Wait
    }

    ## Activate Office using KMS key
    Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /inpkey:FXYTK-NJJ8C-GB6DW-3DYQT-6F7TH" -Wait
    Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /sethst:kms.msgang.com" -Wait
    Start-Process -FilePath "cscript.exe" -ArgumentList "ospp.vbs /act" -Wait

    Write-Output "Office 2021 is activated!"

    Pop-Location
}