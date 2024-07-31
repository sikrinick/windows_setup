# Import dependencies
Import-Module $PSScriptRoot\..\windows\administrator.psm1
Import-Module $PSScriptRoot\setup.psm1

if (RestartAsAdministrator-IfNeeded) {
    Exit
}

$Configuration = Get-Content $PSScriptRoot\..\configuration.json | ConvertFrom-Json

Install-LocalesFromConfiguration `
    -PrimaryLanguageCode $Configuration.PrimaryLanguageCode `
    -PrimaryInputCode $Configuration.PrimaryInputCode `
    -SecondaryLanguages $Configuration.SecondaryLanguages `
    -GeoId $Configuration.GeoId `
    -TimeZone $Configuration.TimeZone

Read-Host "Finished"