
# Returns process object
function Install-Chrome {
    $ChromeInstallProcess = Start-Process -FilePath "$PSScriptRoot\ChromeSetup.exe" -PassThru
    return $ChromeInstallProcess
}

function Set-ChromeAsDefault {
    # TODO. Does nothing
#    http ChromeHTML
#    Start-Process -FilePath "$PSScriptRoot\ChromeSetup.exe" -Wait
#    D:\tools\SetUserFTA.exe  http ChromeHTML
#D:\tools\SetUserFTA.exe  https ChromeHTML
#D:\tools\SetUserFTA.exe  .htm ChromeHTML
#D:\tools\SetUserFTA.exe  .html ChromeHTML
}
