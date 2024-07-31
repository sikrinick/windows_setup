# Import dependencies
Import-Module $PSScriptRoot\windows\administrator.psm1
Import-Module $PSScriptRoot\language\setup.psm1
    
# Check if Administrator
if (RestartAsAdministrator-IfNeeded) {
    Exit
}

# Import configuration
Try {
    $Configuration = Get-Content $PSScriptRoot\configuration.json | ConvertFrom-Json
}
Catch {
    Write-Error "configuration.json was not found. Please, check README.md for setup requirements"
    Read-Host "Press Any Key to Exit"
    Exit
}

# Install languages
Install-LocalesFromConfiguration `
    -PrimaryLanguageCode $Configuration.PrimaryLanguageCode `
    -PrimaryInputCode $Configuration.PrimaryInputCode `
    -SecondaryLanguages $Configuration.SecondaryLanguages `
    -GeoId $Configuration.GeoId `
    -TimeZone $Configuration.TimeZone

Read-Host "Finished"