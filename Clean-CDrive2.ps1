param(
    [ValidateSet(0, 1, 2, 3, 4)]
    [int]$Level = 0,
    
    [switch]$Preview,
    [switch]$Confirm,
    [switch]$Help
)

#========================================
# C Drive Cleanup Tool V2
# Interactive Selection Version
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

function Add-CleanRule {
    param(
        [string]$Name,
        [string]$Description,
        [string[]]$Paths,
        [int]$Level,
        [bool]$IsDangerous = $false,
        [string]$Warning = "",
        [string]$Category = ""
    )
    
    $rule = @{
        Name = $Name
        Description = $Description
        Paths = $Paths
        Level = $Level
        IsDangerous = $IsDangerous
        Warning = $Warning
        Category = $Category
    }
    
    $script:CleanRules += $rule
}

$script:CleanRules = @()

# Level 1: Minimal
Add-CleanRule -Name "Windows Temp" -Description "Windows system temp files" -Paths @("C:\Windows\Temp") -Level 1 -Category "System"
Add-CleanRule -Name "User Temp" -Description "User temp folder" -Paths @($env:TEMP) -Level 1 -Category "System"

# Level 2: Normal
Add-CleanRule -Name "npm Cache" -Description "Node.js package manager cache" -Paths @("$env:USERPROFILE\AppData\Local\npm-cache") -Level 2 -Category "DevTools"
Add-CleanRule -Name "pip Cache" -Description "Python package manager cache" -Paths @("$env:USERPROFILE\AppData\Local\pip") -Level 2 -Category "DevTools"
Add-CleanRule -Name "OfficePLUS Cache" -Description "WPS Office PLUS cache" -Paths @("$env:USERPROFILE\AppData\Local\OfficePLUS") -Level 2 -Category "Office"
Add-CleanRule -Name "GitHub Desktop Cache" -Description "GitHub Desktop cache" -Paths @("$env:USERPROFILE\AppData\Local\GitHubDesktop") -Level 2 -Category "DevTools"

# Level 3: Deep - User selectable
Add-CleanRule -Name "JetBrains IDE Cache" -Description "IntelliJ IDEA/WebStorm/PyCharm IDE cache" -Paths @("$env:USERPROFILE\AppData\Local\JetBrains","$env:APPDATA\JetBrains") -Level 3 -Category "DevTools"
Add-CleanRule -Name "VS Code Cache" -Description "Visual Studio Code cache" -Paths @("$env:USERPROFILE\AppData\Roaming\Code") -Level 3 -Category "DevTools"
Add-CleanRule -Name "npm Global Cache" -Description "npm global cache" -Paths @("$env:APPDATA\npm") -Level 3 -Category "DevTools"
Add-CleanRule -Name "Python Local Cache" -Description "Python local installation cache" -Paths @("$env:APPDATA\Python") -Level 3 -Category "DevTools"
Add-CleanRule -Name "PyCharm Cache" -Description "PyCharm dedicated cache" -Paths @("$env:USERPROFILE\.PyCharm*") -Level 3 -Category "DevTools"

Add-CleanRule -Name "Chrome Cache" -Description "Google Chrome browser cache" -Paths @("$env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Cache") -Level 3 -Category "Browser"
Add-CleanRule -Name "Edge Cache" -Description "Microsoft Edge browser cache" -Paths @("$env:USERPROFILE\AppData\Local\Microsoft\Edge\User Data\Default\Cache") -Level 3 -Category "Browser"
Add-CleanRule -Name "Firefox Cache" -Description "Mozilla Firefox browser cache" -Paths @("$env:USERPROFILE\AppData\Local\Mozilla\Firefox\Profiles\*\cache2") -Level 3 -Category "Browser"

Add-CleanRule -Name "Kingsoft Cache" -Description "WPS Office cache files" -Paths @("$env:APPDATA\kingsoft") -Level 3 -Category "Office"

Add-CleanRule -Name "QQ Cache" -Description "QQ chat records and cache (DANGEROUS!)" -Paths @("$env:APPDATA\Tencent\QQ","$env:USERPROFILE\AppData\Local\Tencent\QQ") -Level 3 -IsDangerous $true -Warning "Contains chat records, backup first!" -Category "IM"
Add-CleanRule -Name "WeChat Cache" -Description "WeChat cache files (DANGEROUS!)" -Paths @("$env:APPDATA\Tencent\WeChat","$env:USERPROFILE\AppData\Local\Tencent\WeChat") -Level 3 -IsDangerous $true -Warning "Contains chat records and files, backup first!" -Category "IM"
Add-CleanRule -Name "DingTalk Cache" -Description "DingTalk cache (re-login required)" -Paths @("$env:APPDATA\DingTalk","$env:USERPROFILE\AppData\Local\DingTalk","$env:USERPROFILE\AppData\Local\DingTalk_133","$env:USERPROFILE\AppData\Local\DingTalk_108") -Level 3 -IsDangerous $true -Warning "Re-login required after clean" -Category "IM"

Add-CleanRule -Name "iFlow Cache" -Description "iFlow AI cache" -Paths @("$env:USERPROFILE\.iflow\history","$env:USERPROFILE\.iflow\temp") -Level 3 -Category "Apps"

# Level 4: Full
Add-CleanRule -Name "0install Cache" -Description "0install software distribution cache" -Paths @("$env:USERPROFILE\AppData\Local\0install.net") -Level 4 -Category "Apps"
Add-CleanRule -Name "NVIDIA Cache" -Description "NVIDIA driver cache" -Paths @("$env:APPDATA\NVIDIA") -Level 4 -Category "Driver"
Add-CleanRule -Name "Adobe Cache" -Description "Adobe software cache" -Paths @("$env:APPDATA\Adobe") -Level 4 -Category "Apps"
Add-CleanRule -Name "Baidu Netdisk Cache" -Description "Baidu Netdisk cache files" -Paths @("$env:APPDATA\baidunetdisk") -Level 4 -Category "Apps"
Add-CleanRule -Name "Quark Cache" -Description "Quark netdisk cache files" -Paths @("$env:USERPROFILE\AppData\Local\Quark") -Level 4 -Category "Apps"
Add-CleanRule -Name "Netease Cache" -Description "Netease software cache" -Paths @("$env:USERPROFILE\AppData\Local\Netease") -Level 4 -Category "Apps"

function Show-Levels {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       C Drive Cleanup Tool V2" -ForegroundColor Cyan
    Write-Host "       Interactive Selection Version" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Level 1 (Minimal)   - Temp files only" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Level 2 (Normal)    - Common cache (default)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Level 3 (Deep)      - Selectable items (interactive)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Level 4 (Full)      - All optional items" -ForegroundColor Red
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Level 0             - Detection only" -ForegroundColor Gray
    Write-Host ""
}

function Show-Plan {
    param([int]$Level)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       Cleanup Plan (Level: $Level)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $totalSize = 0
    $rulesToClean = $script:CleanRules | Where-Object { $_.Level -le $Level }
    
    $safeRules = $rulesToClean | Where-Object { -not $_.IsDangerous }
    $dangerRules = $rulesToClean | Where-Object { $_.IsDangerous }
    
    Write-Host "[Safe Items]" -ForegroundColor Green
    foreach ($rule in $safeRules) {
        $size = 0
        foreach ($path in $rule.Paths) { $size += Get-FolderSize -Path $path }
        $sizeGB = [math]::Round($size / 1GB, 2)
        $totalSize += $size
        Write-Host "  L$($rule.Level) $($rule.Name): $sizeGB GB" -ForegroundColor White
    }
    
    if ($dangerRules.Count -gt 0) {
        Write-Host ""
        Write-Host "[Dangerous Items]" -ForegroundColor Red
        foreach ($rule in $dangerRules) {
            $size = 0
            foreach ($path in $rule.Paths) { $size += Get-FolderSize -Path $path }
            $sizeGB = [math]::Round($size / 1GB, 2)
            $totalSize += $size
            Write-Host "  L$($rule.Level) $($rule.Name): $sizeGB GB" -ForegroundColor Red
            Write-Host "           Warning: $($rule.Warning)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Estimated space: $([math]::Round($totalSize / 1GB, 2)) GB" -ForegroundColor Yellow
    
    return $totalSize
}

function Invoke-Cleanup {
    param(
        [int]$Level,
        [switch]$AutoConfirm,
        [array]$SelectedRules
    )
    
    $dangerRules = $SelectedRules | Where-Object { $_.IsDangerous }
    
    if ($dangerRules.Count -gt 0 -and -not $AutoConfirm) {
        Write-Host ""
        Write-Host "WARNING: Dangerous items detected!" -ForegroundColor Red
        Write-Host ""
        foreach ($rule in $dangerRules) {
            Write-Host "  - $($rule.Name): $($rule.Warning)" -ForegroundColor Yellow
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
    
    foreach ($rule in $SelectedRules) {
        foreach ($path in $rule.Paths) {
            if (Test-Path $path) {
                $beforeSize = Get-FolderSize -Path $path
                try {
                    Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                    $totalCleaned += $beforeSize
                    $color = if ($rule.IsDangerous) { "Red" } else { "Green" }
                    Write-Host "  [Cleaned] $($rule.Name)" -ForegroundColor $color
                }
                catch {
                    Write-Host "  [Failed] $($rule.Name)" -ForegroundColor Red
                }
            }
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "       Cleanup Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Space freed: $([math]::Round($totalCleaned / 1GB, 2)) GB" -ForegroundColor Yellow
    
    $drive = Get-PSDrive C
    $usedGB = [math]::Round($drive.Used / 1GB, 2)
    $freeGB = [math]::Round($drive.Free / 1GB, 2)
    Write-Host ""
    Write-Host "C Drive: Used $usedGB GB, Free $freeGB GB" -ForegroundColor Cyan
}

if ($Level -eq 0) {
    Show-Levels
    Write-Host ""
    Write-Host "Estimated space by level:" -ForegroundColor Cyan
    Write-Host ""
    
    for ($l = 1; $l -le 4; $l++) {
        $rulesToClean = $script:CleanRules | Where-Object { $_.Level -le $l }
        $totalSize = 0
        foreach ($rule in $rulesToClean) {
            foreach ($path in $rule.Paths) { $totalSize += Get-FolderSize -Path $path }
        }
        $sizeGB = [math]::Round($totalSize / 1GB, 2)
        Write-Host "  Level $l : $sizeGB GB" -ForegroundColor White
    }
    exit 0
}

if ($Preview) {
    Show-Plan -Level $Level
    exit 0
}

# Execute
$rulesToClean = $script:CleanRules | Where-Object { $_.Level -le $Level }

if ($Confirm) {
    $rulesToClean = $rulesToClean | Where-Object { -not $_.IsDangerous }
}

Invoke-Cleanup -Level $Level -Confirm:$Confirm -SelectedRules $rulesToClean
