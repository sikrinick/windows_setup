# Returns process object
function Install-Chrome {
    $installer = "$env:TEMP\chrome_install.exe"
    Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $installer
    return Start-Process -FilePath $installer -ArgumentList "/silent /install" -PassThru -Wait
}

function Set-ChromeAsDefault {
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList "http", "ChromeHtml" -Wait
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList "https", "ChromeHtml" -Wait
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList ".htm", "ChromeHtml" -Wait
    Start-Process -FilePath "$PSScriptRoot\SetUserFTA.exe" -ArgumentList ".html", "ChromeHtml" -Wait
}
