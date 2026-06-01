function Install-WingetIfMissing {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        return
    }

    Write-Output "winget not found. Installing App Installer..."
    $bundlePath = Join-Path $env:TEMP "AppInstaller.msixbundle"
    Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile $bundlePath -UseBasicParsing
    Add-AppxPackage -Path $bundlePath
    Remove-Item $bundlePath -Force -ErrorAction SilentlyContinue

    # Refresh PATH so the current session can resolve winget.exe
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget installation failed: command not found after installing App Installer."
    }
    Write-Output "winget installed."
}
