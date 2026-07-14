@{
    RootModule = 'PSPowerPrompt.Bootstrap.psm1'
    NestedModules = @()
    ModuleVersion = '0.6.2'
    GUID = '8c15fb86-5578-4c80-9cad-a7d244f6fc4f'
    Author = 'Ingeniero Juan Pablo Llinas Ramirez'
    CompanyName = 'Puro Ingenio Samario'
    Copyright = '(c) 2026 Puro Ingenio Samario'
    Description = 'Professional PowerShell workspace with session capture, secure exports, productivity shortcuts and optional multi-provider AI assistance.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Start-PPWorkSession',
        'Show-PPCorporateWelcome',
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
        'Export-PPJsonlSession',
        'Invoke-PPAIRequest',
        'Invoke-PPExplainCommand',
        'Invoke-PPFixLastError',
        'Get-PPAIStatus',
        'Set-PPAIProvider',
        'Invoke-PPUpdate',
        'Invoke-PPUninstall',
        'Test-PPInstallation'
    )
    AliasesToExport = @(
        'pp-start', 'pp-status', 'pp-new', 'pp-restart', 'pp-help',
        'pp-export', 'pp-export-safe', 'pp-export-jsonl', 'pp-open', 'pp-stop', 'pp-panel',
        'pp-set', 'pp-vars', 'pp-unset', 'pp-go',
        'pp-ask', 'pp-explain', 'pp-fix', 'pp-ai-status', 'pp-ai-config',
        'pp-update', 'pp-uninstall', 'pp-doctor'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('PowerShell', 'Transcript', 'AI', 'OpenAI', 'Gemini', 'DeepSeek', 'HuggingFace', 'Copilot', 'Productivity', 'Security')
            ProjectUri = 'https://github.com/ingllinasramirez/PS-PowerPrompt'
        }
    }
}
