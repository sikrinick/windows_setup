
function Install-PrimaryLanguage {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$LanguageCode
    )
    Write-Output "Installing primary language and installing language pack: $LanguageCode"
    Install-Language $LanguageCode
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

function Set-PrimaryLocale {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$LanguageCode,
        [Parameter(Mandatory=$true, Position=1)]
        [int]$GeoId,
        [Parameter(Mandatory=$true, Position=2)]
        [string]$TimeZone
    )

    Write-Output "Setting $LanguageCode as primary language"

    Set-WinUILanguageOverride -Language $LanguageCode
    Set-WinSystemLocale -SystemLocale $LanguageCode
    Set-WinDefaultInputMethodOverride -InputTip $LanguageCode
    Set-Culture $LanguageCode
    
    Set-PreferredLanguage $LanguageCode
    Set-SystemPreferredUILanguage $LanguageCode
    Set-SystemLanguage $LanguageCode

    # Set location to Ukraine
    Set-WinHomeLocation -GeoId $GeoId

    # Set time zone to Kyiv
    Set-TimeZone -Id $TimeZone

    # TODO! Set primary locale settings as default for new and system users
}
