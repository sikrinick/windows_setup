function Install-LocalesFromConfiguration {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$PrimaryLanguageCode,
        [Parameter(Mandatory=$true, Position=1)]
        [string[]]$SecondaryLanguages,
        [Parameter(Mandatory=$true, Position=2)]
        [int]$GeoId,
        [Parameter(Mandatory=$true, Position=3)]
        [string]$TimeZone
    )

    # Install languages
    Install-PrimaryLanguage -LanguageCode $PrimaryLanguageCode
    foreach ($LanguageCode in $SecondaryLanguages) {
        Install-SecondaryLanguage -LanguageCode $LanguageCode
    }

    # Remove not used languages
    $LanguagesToKeep = @($PrimaryLanguageCode) + $SecondaryLanguages
    Remove-OtherLanguages -LanguagesToKeep $LanguagesToKeep

    # Set locale
    Set-LocaleSettings `
        -GeoId $GeoId `
        -TimeZone $TimeZone

    # TODO! Set primary locale settings as default for new and system users

    Start-Process ms-settings:regionlanguage
}

function Install-PrimaryLanguage {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$LanguageCode
    )
    Write-Output "Installing primary language and installing language pack: $LanguageCode"
    Install-Language -Language $LanguageCode -CopyToSettings
}

function Install-SecondaryLanguage {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$LanguageCode
    )
    Write-Output "Installing secondary language: $LanguageCode"
    Add-WindowsCapability -Online -Name "Language.Basic~~~$LanguageCode~0.0.1.0" -ErrorAction Stop
}

function Remove-OtherLanguages {
    Param(
        [Parameter(Mandatory=$true)]
        [string[]]$LanguagesToKeep
    )
    Set-WinUserLanguageList $LanguagesToKeep -Force
}

function Set-LocaleSettings {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [int]$GeoId,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$TimeZone
    )

    Write-Output "Setting $LanguageCode as primary language"

    Set-WinHomeLocation -GeoId $GeoId
    Set-TimeZone -Id $TimeZone
}

Export-ModuleMember -Function Install-LocalesFromConfiguration
