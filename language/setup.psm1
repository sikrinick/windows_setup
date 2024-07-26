function Install-LocalesFromConfiguration {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$PrimaryLanguageCode,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$PrimaryInputCode,
        [Parameter(Mandatory=$true, Position=2)]
        [string[]]$SecondaryLanguages,
        [Parameter(Mandatory=$true, Position=3)]
        [int]$GeoId,
        [Parameter(Mandatory=$true, Position=4)]
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
    Copy-UserInternationalSettingsToWelcomeAndNewUser `
        -LanguageCode $PrimaryLanguageCode `
        -InputCode $PrimaryInputCode `
        -GeoId $GeoId `
        -TimeZone $TimeZone

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

function Copy-UserInternationalSettingsToWelcomeAndNewUser {
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$LanguageCode,
        [Parameter(Mandatory=$true, Position=1)]
        [string]$InputCode,
        [Parameter(Mandatory=$true, Position=2)]
        [int]$GeoId,
        [Parameter(Mandatory=$true, Position=3)]
        [string]$TimeZone
    )

    $isWin11 = (Get-WmiObject Win32_OperatingSystem).Caption -Match "Windows 11"

    if ($isWin11) {
        Copy-UserInternationalSettingsToSystem
    } else {
        $ProfileXml = @"
<gs:GlobalizationServices xmlns:gs="urn:longhornGlobalizationUnattend"> 
<!--User List-->
<gs:UserList>
    <gs:User UserID="Current" CopySettingsToDefaultUserAcct="true" CopySettingsToSystemAcct="true"/> 
</gs:UserList>
<gs:UserLocale> 
    <gs:Locale Name="$($LanguageCode)" SetAsCurrent="true"/> 
</gs:UserLocale>
<!--location--> 
<gs:LocationPreferences> 
    <gs:GeoID Value="$($GeoId)"/> 
</gs:LocationPreferences>
<gs:InputPreferences>
    <gs:InputLanguageID Action="add" ID="0809:00000809" Default="true"/> 
</gs:InputPreferences>
"@

        # Save the profile XML to a temporary file
        $TempProfilePath = [System.IO.Path]::GetTempFileName() + ".xml"
        Set-Content -Path $TempProfilePath -Value $ProfileXml

        Start-Process -FilePath "$env:SystemRoot\System32\control.exe" -ArgumentList "intl.cpl,,/f:`"$TempProfilePath`"" -Wait
        
        # Clear
        Remove-Item -Path $TempProfilePath
    }
}

Export-ModuleMember -Function Install-LocalesFromConfiguration
