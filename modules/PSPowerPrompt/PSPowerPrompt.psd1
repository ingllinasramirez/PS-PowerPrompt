@{
    RootModule = 'PSPowerPrompt.psm1'
    NestedModules = @('PSPowerPrompt.Maintenance.psm1')
    ModuleVersion = '0.5.0'
    GUID = '8c15fb86-5578-4c80-9cad-a7d244f6fc4f'
    Author = 'Juan Pablo Llinas Ramirez'
    CompanyName = 'Community'
    Copyright = '(c) 2026'
    Description = 'Session capture, AI-friendly export, path shortcuts, sounds, maintenance, diagnostics, and assistant bootstrap for PowerShell.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Start-PPWorkSession',
        'Get-PPStatus',
        'New-PPSession',
        'Restart-PPSession',
        'Show-PPHelp',
        'Export-PPSession',
        'Export-PPLatestTranscript',
        'Open-PPLatest',
        'Open-PPExportFolder',
        'Stop-PPSession',
        'Show-PPPanel',
        'Set-PPSessionVariable',
        'Get-PPSessionVariable',
        'Remove-PPSessionVariable',
        'Set-PPLocation',
        'Protect-PPText',
        'Export-PPSafeSession',
        'Invoke-PPUpdate',
        'Invoke-PPUninstall',
        'Test-PPInstallation'
    )
    AliasesToExport = @(
        'pp-start', 'pp-status', 'pp-new', 'pp-restart', 'pp-help',
        'pp-export', 'pp-export-safe', 'pp-open', 'pp-stop', 'pp-panel',
        'pp-set', 'pp-vars', 'pp-unset', 'pp-go',
        'pp-update', 'pp-uninstall', 'pp-doctor'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('PowerShell', 'Transcript', 'AI', 'Productivity', 'Shortcuts', 'Session', 'Maintenance', 'Security')
            ProjectUri = 'https://github.com/ingllinasramirez/PS-PowerPrompt'
        }
    }
}
