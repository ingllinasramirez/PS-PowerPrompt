Set-StrictMode -Version Latest

function Get-PPInstallRoot {
    Join-Path $HOME '.ps-powerprompt'
}

function Protect-PPText {
    [CmdletBinding()]
    param([Parameter(Mandatory, ValueFromPipeline)][AllowEmptyString()][string]$Text)

    process {
        $protected = $Text

        $patterns = @(
            @{ Pattern = '(?im)(authorization\s*:\s*bearer\s+)[^\s"'']+'; Replacement = '$1[REDACTED]' },
            @{ Pattern = '(?im)(authorization\s*:\s*basic\s+)[^\s"'']+'; Replacement = '$1[REDACTED]' },
            @{ Pattern = '(?im)((?:api[_-]?key|access[_-]?token|auth[_-]?token|client[_-]?secret|password|passwd|pwd)\s*[:=]\s*)[^\s;,"'']+'; Replacement = '$1[REDACTED]' },
            @{ Pattern = '(?im)(AccountKey\s*=\s*)[^;\s]+'; Replacement = '$1[REDACTED]' },
            @{ Pattern = '(?im)(SharedAccessSignature\s*=\s*)[^\r\n]+'; Replacement = '$1[REDACTED]' },
            @{ Pattern = '(?im)(mongodb(?:\+srv)?://[^:\s/]+:)[^@\s]+@'; Replacement = '$1[REDACTED]@' },
            @{ Pattern = '(?im)((?:mysql|postgres(?:ql)?|sqlserver)://[^:\s/]+:)[^@\s]+@'; Replacement = '$1[REDACTED]@' }
        )

        foreach ($item in $patterns) {
            $protected = [regex]::Replace($protected, $item.Pattern, $item.Replacement)
        }

        return $protected
    }
}

function Export-PPSafeSession {
    [CmdletBinding()]
    param([ValidateSet('Markdown','Text','Json')][string]$Format)

    $exportCommand = Get-Command Export-PPSession -ErrorAction Stop
    $path = if ($PSBoundParameters.ContainsKey('Format')) {
        & $exportCommand -Format $Format
    } else {
        & $exportCommand
    }

    if (-not $path -or -not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw 'No fue posible localizar el archivo exportado.'
    }

    $content = Get-Content -LiteralPath $path -Raw
    $safeContent = Protect-PPText -Text $content
    Set-Content -LiteralPath $path -Value $safeContent -Encoding utf8

    Write-Host "Exportacion protegida para compartir: $path" -ForegroundColor Green
    return $path
}

function Invoke-PPUpdate {
    [CmdletBinding()]
    param()

    $scriptPath = Join-Path (Get-PPInstallRoot) 'scripts\update.ps1'
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        throw "No se encontro el actualizador en: $scriptPath"
    }

    & $scriptPath
}

function Invoke-PPUninstall {
    [CmdletBinding()]
    param([switch]$RemoveData)

    $scriptPath = Join-Path (Get-PPInstallRoot) 'scripts\uninstall.ps1'
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        throw "No se encontro el desinstalador en: $scriptPath"
    }

    & $scriptPath -RemoveData:$RemoveData
}

function Test-PPInstallation {
    [CmdletBinding()]
    param()

    $root = Get-PPInstallRoot
    $checks = [ordered]@{
        InstallRoot = Test-Path -LiteralPath $root -PathType Container
        Configuration = Test-Path -LiteralPath (Join-Path $root 'config\settings.json') -PathType Leaf
        ModuleManifest = Test-Path -LiteralPath (Join-Path $root 'modules\PSPowerPrompt\PSPowerPrompt.psd1') -PathType Leaf
        MainModule = Test-Path -LiteralPath (Join-Path $root 'modules\PSPowerPrompt\PSPowerPrompt.psm1') -PathType Leaf
        MaintenanceModule = Test-Path -LiteralPath (Join-Path $root 'modules\PSPowerPrompt\PSPowerPrompt.Maintenance.psm1') -PathType Leaf
        SoundPlayer = Test-Path -LiteralPath (Join-Path $root 'scripts\Play-PowerPromptStartupSound.ps1') -PathType Leaf
        Updater = Test-Path -LiteralPath (Join-Path $root 'scripts\update.ps1') -PathType Leaf
        Uninstaller = Test-Path -LiteralPath (Join-Path $root 'scripts\uninstall.ps1') -PathType Leaf
        ProfileBootstrap = $false
    }

    if (Test-Path -LiteralPath $PROFILE.CurrentUserAllHosts -PathType Leaf) {
        $profileContent = Get-Content -LiteralPath $PROFILE.CurrentUserAllHosts -Raw -ErrorAction SilentlyContinue
        $checks.ProfileBootstrap = $profileContent -match '# >>> PS-PowerPrompt >>>'
    }

    $requiredCommands = @(
        'pp-status','pp-export','pp-export-safe','pp-open','pp-stop','pp-panel',
        'pp-set','pp-vars','pp-unset','pp-go','pp-new','pp-restart','pp-help',
        'pp-update','pp-uninstall','pp-doctor'
    )

    $commandChecks = foreach ($command in $requiredCommands) {
        [pscustomobject]@{
            Check = "Command:$command"
            Passed = [bool](Get-Command $command -ErrorAction SilentlyContinue)
        }
    }

    $fileChecks = foreach ($item in $checks.GetEnumerator()) {
        [pscustomobject]@{
            Check = $item.Key
            Passed = [bool]$item.Value
        }
    }

    $results = @($fileChecks) + @($commandChecks)
    $results | Format-Table -AutoSize

    if ($results.Passed -contains $false) {
        Write-Warning 'Se encontraron validaciones pendientes.'
        return $false
    }

    Write-Host 'PS-PowerPrompt esta instalado correctamente.' -ForegroundColor Green
    return $true
}

Set-Alias pp-export-safe Export-PPSafeSession
Set-Alias pp-update Invoke-PPUpdate
Set-Alias pp-uninstall Invoke-PPUninstall
Set-Alias pp-doctor Test-PPInstallation

Export-ModuleMember -Function Protect-PPText, Export-PPSafeSession, Invoke-PPUpdate, Invoke-PPUninstall, Test-PPInstallation -Alias pp-export-safe, pp-update, pp-uninstall, pp-doctor
