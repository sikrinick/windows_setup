# Returns process object
function Install-Chrome {
    return Start-Process -FilePath "winget" -ArgumentList @(
        "install",
        "--id", "Google.Chrome",
        "--exact",
        "--silent",
        "--accept-package-agreements",
        "--accept-source-agreements"
    ) -PassThru -NoNewWindow
}

function Set-ChromeAsDefault {
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList "http", "ChromeHtml" -Wait
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList "https", "ChromeHtml" -Wait
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList ".htm", "ChromeHtml" -Wait
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList ".html", "ChromeHtml" -Wait
}
