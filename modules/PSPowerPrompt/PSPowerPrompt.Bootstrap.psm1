Set-StrictMode -Version Latest

$sessionModulePath = Join-Path $PSScriptRoot 'PSPowerPrompt.psm1'
$maintenanceModulePath = Join-Path $PSScriptRoot 'PSPowerPrompt.Maintenance.psm1'
$aiModulePath = Join-Path $PSScriptRoot 'PSPowerPrompt.AI.psm1'

Import-Module $sessionModulePath -Force -Global:$false
Import-Module $maintenanceModulePath -Force -Global:$false
Import-Module $aiModulePath -Force -Global:$false

function