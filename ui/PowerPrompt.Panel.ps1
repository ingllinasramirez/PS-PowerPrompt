Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$manifest = Join-Path $HOME '.ps-powerprompt\modules\PSPowerPrompt\PSPowerPrompt.psd1'
Import-Module $manifest -Force

$form = New-Object System.Windows.Forms.Form
$form.Text = 'PS-PowerPrompt'
$form.Size = New-Object System.Drawing.Size(390, 285)
$form.StartPosition = 'CenterScreen'
$form.TopMost = $true
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(26, 32, 44)
$form.ForeColor = [System.Drawing.Color]::White

$title = New-Object System.Windows.Forms.Label
$title.Text = 'PS-PowerPrompt'
$title.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(22, 18)
$form.Controls.Add($title)

$status = New-Object System.Windows.Forms.Label
$status.Text = 'Panel listo para exportar la consola.'
$status.AutoSize = $true
$status.Location = New-Object System.Drawing.Point(24, 58)
$form.Controls.Add($status)

function Add-PPButton {
    param([string]$Text,[int]$X,[int]$Y,[int]$Width,[scriptblock]$OnClick)
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Location = New-Object System.Drawing.Point($X, $Y)
    $button.Size = New-Object System.Drawing.Size($Width, 42)
    $button.FlatStyle = 'Flat'
    $button.BackColor = [System.Drawing.Color]::FromArgb(49, 130, 206)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.Add_Click($OnClick)
    $form.Controls.Add($button)
}

Add-PPButton 'Exportar para IA' 24 92 330 {
    try {
        $path = Export-PPLatestTranscript
        $status.Text = "Exportado: $([System.IO.Path]::GetFileName($path))"
    } catch {
        $status.Text = "Error: $($_.Exception.Message)"
    }
}

Add-PPButton 'Abrir ultimo archivo' 24 142 160 {
    try { Open-PPLatest } catch { $status.Text = "Error: $($_.Exception.Message)" }
}

Add-PPButton 'Abrir carpeta' 194 142 160 {
    try { Open-PPExportFolder } catch { $status.Text = "Error: $($_.Exception.Message)" }
}

Add-PPButton 'Cerrar panel' 24 192 330 { $form.Close() }

[void]$form.ShowDialog()
