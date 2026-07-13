@{
    RootModule = 'PSPowerPrompt.psm1'
    ModuleVersion = '0.2.0'
    GUID = '8c15fb86-5578-4c80-9cad-a7d244f6fc4f'
    Author = 'Juan Pablo Llinas Ramirez'
    CompanyName = 'Community'
    Copyright = '(c) 2026'
    Description = 'Session capture, AI-friendly export, and assistant bootstrap for PowerShell.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Start-PPWorkSession',
        'Get-PPStatus',
        'Export-PPSession',
        'Export-PPLatestTranscript',
        'Open-PPLatest',
        'Open-PPExportFolder',
        'Stop-PPSession',
        'Show-PPPanel'
    )
    AliasesToExport = @('pp-start', 'pp-status', 'pp-export', 'pp-open', 'pp-stop', 'pp-panel')
    CmdletsToExport = @()
    VariablesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('PowerShell', 'Transcript', 'AI', 'Productivity')
            ProjectUri = 'https://github.com/ingllinasramirez/PS-PowerPrompt'
        }
    }
}
