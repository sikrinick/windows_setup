function Update-Windows {
    Write-Output "Adding NuGet Repository"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Install-PackageProvider -Name NuGet -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

    Write-Output "Installing PSWindowUpdate from PSGallery"
    Install-Module -Name PSWindowsUpdate -Verbose
    Import-Module PSWindowsUpdate
    
    Write-Output "Installing Windows Updates"
    Install-WindowsUpdate -AcceptAll -IgnoreReboot
}
