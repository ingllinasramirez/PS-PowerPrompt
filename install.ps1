[CmdletBinding()]
param([switch]$NoLaunch)

$ErrorActionPreference = 'Stop'

function Write-Step { param([string]$Message) Write-Host "[PS-PowerPrompt] $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-WarnMessage { param([string]$Message) Write-Host "[AVISO] $Message" -ForegroundColor Yellow }
