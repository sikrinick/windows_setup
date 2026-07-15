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

    # 1. Install language packs
    Install-PrimaryLanguage -LanguageCode $PrimaryLanguageCode
    foreach ($LanguageCode in $SecondaryLanguages) {
        Install-SecondaryLanguage -LanguageCode $LanguageCode
    }

    # 2. Keep only the requested languages on the current user (default keyboards)
    $LanguagesToKeep = @($PrimaryLanguageCode) + $SecondaryLanguages
    Set-WinUserLanguageList -LanguageList $LanguagesToKeep -Force

    # 3. Format, UI language, system locale, location, time zone
    Set-LocaleSettings `
        -LanguageCode $PrimaryLanguageCode `
        -GeoId        $GeoId `
        -TimeZone     $TimeZone

    # 4. Copy the now-configured user settings to Welcome screen + new user accounts
    Copy-UserInternationalSettingsToWelcomeAndNewUser `
        -LanguageCode $PrimaryLanguageCode `
        -InputCode    $PrimaryInputCode `
        -GeoId        $GeoId

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
    $isWin11 = (Get-CimInstance Win32_OperatingSystem).BuildNumber -ge 22000

    if ($isWin11) {
      Install-Language -Language $LanguageCode -ExcludeFeatures -ErrorAction Stop
    } else {
      try {
        Install-Language -Language $LanguageCode -ExcludeFeatures -ErrorAction -Stop
      } catch {
        Add-WindowsCapability -Online -Name "Language.Basic~~~$LanguageCode~0.0.1.0" -ErrorAction Stop
      }
    }
}

function Set-LocaleSettings {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$LanguageCode,
        [Parameter(Mandatory=$true)]
        [int]$GeoId,
        [Parameter(Mandatory=$true)]
        [string]$TimeZone
    )

    # Regional format (date 'dd.MM.yyyy', currency, number separators, etc.)
    Set-Culture -CultureInfo $LanguageCode

    # Override the displayed UI language
    Set-WinUILanguageOverride -Language $LanguageCode

    # Home location (Country/Region)
    Set-WinHomeLocation -GeoId $GeoId

    # Time zone
    Set-TimeZone -Id $TimeZone

    # System locale for non-Unicode programs. Takes effect at next reboot.
    Try {
        Set-WinSystemLocale -SystemLocale $LanguageCode
    }
    Catch {
        Write-Warning "Could not set system locale to ${LanguageCode}: $_"
    }
}

function Copy-UserInternationalSettingsToWelcomeAndNewUser {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$LanguageCode,
        [Parameter(Mandatory=$true)]
        [string]$InputCode,
        [Parameter(Mandatory=$true)]
        [int]$GeoId
    )

    # Modern path (Win 10 1809+ and Win 11): one cmdlet, both checkboxes from the
    # Region > Administrative dialog.
    if (Get-Command Copy-UserInternationalSettingsToSystem -ErrorAction SilentlyContinue) {
        Try {
            Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true
            Write-Output "Copied international settings to Welcome screen and new user accounts."
            return
        }
        Catch {
            Write-Warning "Copy-UserInternationalSettingsToSystem failed, falling back to control.exe: $_"
        }
    }

    # Legacy fallback for very old Windows 10 builds: drive intl.cpl with an
    # unattend XML. Uses the configured input code, not a hardcoded one.
    $ProfileXml = @"
<gs:GlobalizationServices xmlns:gs="urn:longhornGlobalizationUnattend">
<gs:UserList>
    <gs:User UserID="Current" CopySettingsToDefaultUserAcct="true" CopySettingsToSystemAcct="true"/>
</gs:UserList>
<gs:UserLocale>
    <gs:Locale Name="$LanguageCode" SetAsCurrent="true"/>
</gs:UserLocale>
<gs:LocationPreferences>
    <gs:GeoID Value="$GeoId"/>
</gs:LocationPreferences>
<gs:InputPreferences>
    <gs:InputLanguageID Action="add" ID="$InputCode" Default="true"/>
</gs:InputPreferences>
</gs:GlobalizationServices>
"@

    $TempProfilePath = [System.IO.Path]::GetTempFileName() + ".xml"
    Try {
        Set-Content -Path $TempProfilePath -Value $ProfileXml -Encoding UTF8
        Start-Process -FilePath "$env:SystemRoot\System32\control.exe" `
            -ArgumentList "intl.cpl,,/f:`"$TempProfilePath`"" -Wait
    }
    Finally {
        Remove-Item -Path $TempProfilePath -ErrorAction Ignore
    }
}

Export-ModuleMember -Function Install-LocalesFromConfiguration
