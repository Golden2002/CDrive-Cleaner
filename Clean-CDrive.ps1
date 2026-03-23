param(
    [ValidateSet(0, 1, 2, 3, 4)]
    [int]$Level = 0,
    
    [switch]$Preview,
    [switch]$Confirm,
    [switch]$Help
)

#========================================
# C Drive Cleanup Tool
# Extensible PowerShell Script with Multiple Cleanup Levels
#========================================

#========================================
# Helper Functions
#========================================

function Get-FolderSize {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) { return 0 }
    
    try {
        $size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        return if ($size) { $size } else { 0 }
    }
    catch { return 0 }
}

#========================================
# Add Rule Function
#========================================

function Add-CleanRule {
    param(
        [string]$Name,
        [string]$Description,
        [string[]]$Paths,
        [int]$Level,
        [bool]$IsDangerous = $false,
        [string]$Warning = ""
    )
    
    $rule = @{
        Name = $Name
        Description = $Description
        Paths = $Paths
        Level = $Level
        IsDangerous = $IsDangerous
        Warning = $Warning
    }
    
    $script:CleanRules += $rule
}

# Rules array
$script:CleanRules = @()

#========================================
# Define Cleanup Rules
#========================================

# Level 1: Minimal
Add-CleanRule -Name "Windows Temp" -Description "Windows system temp files" -Paths @("C:\Windows\Temp") -Level 1
Add-CleanRule -Name "User Temp" -Description "Current user temp folder" -Paths @($env:TEMP) -Level 1

# Level 2: Normal
Add-CleanRule -Name "npm Cache" -Description "Node.js package manager cache" -Paths @("$env:USERPROFILE\AppData\Local\npm-cache") -Level 2
Add-CleanRule -Name "pip Cache" -Description "Python package manager cache" -Paths @("$env:USERPROFILE\AppData\Local\pip") -Level 2
Add-CleanRule -Name "OfficePLUS Cache" -Description "WPS Office PLUS cache" -Paths @("$env:USERPROFILE\AppData\Local\OfficePLUS") -Level 2
Add-CleanRule -Name "GitHub Desktop Cache" -Description "GitHub Desktop cache" -Paths @("$env:USERPROFILE\AppData\Local\GitHubDesktop") -Level 2

# Level 3: Deep
Add-CleanRule -Name "Tencent Files" -Description "QQ/WeChat data (may contain chat records)" -Paths @("$env:APPDATA\Tencent","$env:USERPROFILE\AppData\Local\Tencent") -Level 3 -IsDangerous $true -Warning "Contains chat records, backup before clean!"
Add-CleanRule -Name "Kingsoft Cache" -Description "WPS Office cache files" -Paths @("$env:APPDATA\kingsoft") -Level 3
Add-CleanRule -Name "DingTalk Cache" -Description "DingTalk cache (need re-login after clean)" -Paths @("$env:APPDATA\DingTalk","$env:USERPROFILE\AppData\Local\DingTalk","$env:USERPROFILE\AppData\Local\DingTalk_133","$env:USERPROFILE\AppData\Local\DingTalk_108") -Level 3 -IsDangerous $true -Warning "Need re-login after clean"
Add-CleanRule -Name "JetBrains Cache" -Description "IntelliJ IDEA/WebStorm IDE cache" -Paths @("$env:USERPROFILE\AppData\Local\JetBrains","$env:APPDATA\JetBrains") -Level 3
Add-CleanRule -Name "Chrome Cache" -Description "Google Chrome browser cache" -Paths @("$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Cache") -Level 3
Add-CleanRule -Name "Python Local Cache" -Description "Python local installation cache" -Paths @("$env:APPDATA\Python") -Level 3

# Level 4: Full
Add-CleanRule -Name "0install Cache" -Description "0install software distribution cache" -Paths @("$env:USERPROFILE\AppData\Local\0install.net") -Level 4
Add-CleanRule -Name "NVIDIA Cache" -Description "NVIDIA driver cache" -Paths @("$env:APPDATA\NVIDIA") -Level 4
Add-CleanRule -Name "Adobe Cache" -Description "Adobe software cache" -Paths @("$env:APPDATA\Adobe") -Level 4
Add-CleanRule -Name "Baidu Netdisk Cache" -Description "Baidu Netdisk cache files" -Paths @("$env:APPDATA\baidunetdisk") -Level 4
Add-CleanRule -Name "Quark Cache" -Description "Quark netdisk cache files" -Paths @("$env:USERPROFILE\AppData\Local\Quark") -Level 4
Add-CleanRule -Name "Netease Cache" -Description "Netease software cache (CloudMusic etc)" -Paths @("$env:USERPROFILE\AppData\Local\Netease") -Level 4

#========================================
# Core Functions
#========================================

function Show-Levels {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       Available Cleanup Levels" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Level 1 (Minimal)  - Temp files only" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Level 2 (Normal)   - + Common cache (npm/pip/GitHub)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Level 3 (Deep)    - + Large apps (Tencent/DingTalk/JetBrains)" -ForegroundColor Yellow
    Write-Host "      WARNING: May affect some applications"
    Write-Host ""
    Write-Host "  Level 4 (Full)    - + All optional apps" -ForegroundColor Red
    Write-Host "      WARNING: May require re-login for apps"
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Level 0           - Detection only" -ForegroundColor Gray
    Write-Host "      Show estimated space for each level"
    Write-Host ""
}

function Show-Plan {
    param([int]$Level)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       Cleanup Plan Preview (Level: $Level)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $totalSize = 0
    $rulesToClean = $script:CleanRules | Where-Object { $_.Level -le $Level }
    
    $safeRules = $rulesToClean | Where-Object { -not $_.IsDangerous }
    $dangerRules = $rulesToClean | Where-Object { $_.IsDangerous }
    
    # Safe items
    Write-Host "[Safe Items]" -ForegroundColor Green
    foreach ($rule in $safeRules) {
        $size = 0
        foreach ($path in $rule.Paths) {
            $size += Get-FolderSize -Path $path
        }
        $sizeGB = [math]::Round($size / 1GB, 2)
        $totalSize += $size
        Write-Host "  [L$($rule.Level)] $($rule.Name): $sizeGB GB" -ForegroundColor White
        Write-Host "           $($rule.Description)" -ForegroundColor Gray
    }
    
    # Dangerous items
    if ($dangerRules.Count -gt 0) {
        Write-Host ""
        Write-Host "[Dangerous Items] (May lose important data)" -ForegroundColor Red
        foreach ($rule in $dangerRules) {
            $size = 0
            foreach ($path in $rule.Paths) {
                $size += Get-FolderSize -Path $path
            }
            $sizeGB = [math]::Round($size / 1GB, 2)
            $totalSize += $size
            Write-Host "  [L$($rule.Level)] $($rule.Name): $sizeGB GB" -ForegroundColor Red
            Write-Host "           Warning: $($rule.Warning)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Estimated space to free: $([math]::Round($totalSize / 1GB, 2)) GB" -ForegroundColor Yellow
    
    return $totalSize
}

function Invoke-Cleanup {
    param(
        [int]$Level,
        [switch]$AutoConfirm
    )
    
    $rulesToClean = $script:CleanRules | Where-Object { $_.Level -le $Level }
    $dangerRules = $rulesToClean | Where-Object { $_.IsDangerous }
    
    # Confirm if has dangerous items
    if ($dangerRules.Count -gt 0 -and -not $AutoConfirm) {
        Write-Host ""
        Write-Host "WARNING: Detected dangerous cleanup items!" -ForegroundColor Red
        Write-Host ""
        $dangerRules | ForEach-Object {
            Write-Host "  - $($_.Name): $($_.Warning)" -ForegroundColor Yellow
        }
        Write-Host ""
        $response = Read-Host "Continue? (y/n)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-Host "Operation cancelled" -ForegroundColor Yellow
            return
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       Starting Cleanup (Level: $Level)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $totalCleaned = 0
    
    foreach ($rule in $rulesToClean) {
        foreach ($path in $rule.Paths) {
            if (Test-Path $path) {
                $beforeSize = Get-FolderSize -Path $path
                try {
                    Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                    $totalCleaned += $beforeSize
                    $color = if ($rule.IsDangerous) { "Red" } else { "Green" }
                    Write-Host "  [Cleaned] $($rule.Name) - $path" -ForegroundColor $color
                }
                catch {
                    Write-Host "  [Failed] $($rule.Name) - $path" -ForegroundColor Red
                }
            }
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       Cleanup Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Space freed: $([math]::Round($totalCleaned / 1GB, 2)) GB" -ForegroundColor Yellow
    
    # Show C drive usage
    $drive = Get-PSDrive C
    $usedGB = [math]::Round($drive.Used / 1GB, 2)
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    Write-Host ""
    Write-Host "C Drive Status: Used $usedGB GB, Free $freeGB GB" -ForegroundColor Cyan
}

#========================================
# Main Entry
#========================================

# Show help if no args
if ($args.Count -eq 0 -and $Level -eq 0) {
    Show-Levels
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       Usage Examples" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  # Preview all levels" -ForegroundColor White
    Write-Host "  .\Clean-CDrive.ps1 -Level 0" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  # Preview Level 2 plan" -ForegroundColor White
    Write-Host "  .\Clean-CDrive.ps1 -Level 2 -Preview" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  # Execute Level 2 (with confirmation)" -ForegroundColor White
    Write-Host "  .\Clean-CDrive.ps1 -Level 2 -Confirm" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  # Execute Level 3 (auto confirm)" -ForegroundColor White
    Write-Host "  .\Clean-CDrive.ps1 -Level 3 -Confirm" -ForegroundColor Gray
    Write-Host ""
    
    exit 0
}

# Preview mode
if ($Preview) {
    Show-Plan -Level $Level
    exit 0
}

# Execute cleanup
Invoke-Cleanup -Level $Level -AutoConfirm:$Confirm
