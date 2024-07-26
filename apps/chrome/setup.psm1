
# Returns process object
function Install-Chrome {
    $ChromeInstallProcess = Start-Process -FilePath "$PSScriptRoot\ChromeSetup.exe" -PassThru
    return $ChromeInstallProcess
}

function Set-ChromeAsDefault {
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList "http", "ChromeHtml" -Wait
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList "https", "ChromeHtml" -Wait
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList ".htm", "ChromeHtml" -Wait
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList ".html", "ChromeHtml" -Wait
}
