<#
.SYNOPSIS
    NVIDIA GPU Freeze Fix Manager (TDR Delay & MPO Disable)
    Target System: High-end NVIDIA GPU (RTX 4090/5090)
    
.DESCRIPTION
    This script manages two specific registry keys to prevent 5-6 second freezing:
    1. TdrDelay (GraphicsDrivers): Increases timeout to 10s to prevent driver reset.
    2. OverlayTestMode (DWM): Disables Multi-Plane Overlay (MPO) to prevent overlay conflicts.
    
    It provides status checks, application of fixes, and rollback options.
#>

# --- Self-Elevation Check ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires Administrator privileges to modify the Registry."
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# --- Configuration ---
$TdrPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
$TdrKey  = "TdrDelay"
$TdrVal  = 10

$MpoPath = "HKLM:\SOFTWARE\Microsoft\Windows\Dwm"
$MpoKey  = "OverlayTestMode"
$MpoVal  = 5

# --- Helper Function: Get Registry Status ---
function Get-RegStatus {
    param ( $Path, $Name, $ExpectedValue )
    
    $exists = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    
    if ($null -eq $exists) {
        return "MISSING (Windows Default)"
    }
    elseif ($exists.$Name -eq $ExpectedValue) {
        return "ACTIVE (Value: $($exists.$Name))"
    }
    else {
        return "MISMATCH (Current: $($exists.$Name), Target: $ExpectedValue)"
    }
}

# --- Helper Function: Apply Registry Key ---
function Set-RegKey {
    param ( $Path, $Name, $Value, $Type = "DWord" )

    Write-Host "------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Action: Applying Fix for $Name" -ForegroundColor Cyan
    
    # Check if path exists, create if not
    if (!(Test-Path $Path)) {
        Write-Host "  > Path not found. Creating: $Path" -ForegroundColor Yellow
        New-Item -Path $Path -Force | Out-Null
    }

    # Check current state
    $current = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    
    if ($current -and $current.$Name -eq $Value) {
        Write-Host "  > Skipped: Key $Name is already set to $Value." -ForegroundColor Green
    }
    else {
        Write-Host "  > Executing: Set-ItemProperty -Path $Path -Name $Name -Value $Value" -ForegroundColor Gray
        try {
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
            Write-Host "  > SUCCESS: $Name set to $Value." -ForegroundColor Green
        }
        catch {
            Write-Host "  > ERROR: Failed to set key. $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# --- Helper Function: Remove Registry Key ---
function Remove-RegKey {
    param ( $Path, $Name )

    Write-Host "------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "Action: Reverting Fix for $Name" -ForegroundColor Magenta

    $current = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue

    if ($null -eq $current) {
        Write-Host "  > Skipped: Key $Name does not exist." -ForegroundColor Green
    }
    else {
        Write-Host "  > Executing: Remove-ItemProperty -Path $Path -Name $Name" -ForegroundColor Gray
        try {
            Remove-ItemProperty -Path $Path -Name $Name -ErrorAction Stop
            Write-Host "  > SUCCESS: $Name removed (Reverted to Default)." -ForegroundColor Green
        }
        catch {
            Write-Host "  > ERROR: Failed to remove key. $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# --- Main Menu Loop ---
do {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "   NVIDIA FREEZE FIX MANAGER (5090/AM5)   " -ForegroundColor Cyan
    Write-Host "=========================================="
    
    # 1. Check Status
    $statusTdr = Get-RegStatus -Path $TdrPath -Name $TdrKey -ExpectedValue $TdrVal
    $statusMpo = Get-RegStatus -Path $MpoPath -Name $MpoKey -ExpectedValue $MpoVal
    
    Write-Host " Current Status:" -ForegroundColor Yellow
    Write-Host "  1. TDR Delay (Timeout Fix) : $statusTdr" -ForegroundColor ($statusTdr -match "ACTIVE" ? "Green" : "White")
    Write-Host "  2. MPO (Overlay Fix)       : $statusMpo" -ForegroundColor ($statusMpo -match "ACTIVE" ? "Green" : "White")
    Write-Host "------------------------------------------"
    
    Write-Host "ACTIONS:"
    Write-Host "  [A] Apply ALL Fixes (Recommended)"
    Write-Host "  [T] Apply TDR Delay ONLY (Safe)"
    Write-Host "  [M] Apply MPO Disable ONLY"
    Write-Host ""
    Write-Host "  [R] Remove ALL Fixes (Revert to Stock)"
    Write-Host "  [1] Remove TDR Delay"
    Write-Host "  [2] Remove MPO Disable"
    Write-Host ""
    Write-Host "  [Q] Quit"
    
    $choice = Read-Host "Select an option"

    switch ($choice.ToUpper()) {
        "A" { 
            Set-RegKey -Path $TdrPath -Name $TdrKey -Value $TdrVal
            Set-RegKey -Path $MpoPath -Name $MpoKey -Value $MpoVal
            Write-Host "`nAll fixes applied. Please REBOOT for changes to take effect." -ForegroundColor Cyan
            Pause
        }
        "T" { 
            Set-RegKey -Path $TdrPath -Name $TdrKey -Value $TdrVal
            Pause
        }
        "M" { 
            Set-RegKey -Path $MpoPath -Name $MpoKey -Value $MpoVal
            Pause
        }
        "R" { 
            Remove-RegKey -Path $TdrPath -Name $TdrKey
            Remove-RegKey -Path $MpoPath -Name $MpoKey
            Write-Host "`nAll fixes removed. Please REBOOT for changes to take effect." -ForegroundColor Cyan
            Pause
        }
        "1" { 
            Remove-RegKey -Path $TdrPath -Name $TdrKey
            Pause
        }
        "2" { 
            Remove-RegKey -Path $MpoPath -Name $MpoKey
            Pause
        }
        "Q" { break }
        Default { Write-Host "Invalid selection." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }

} while ($choice.ToUpper() -ne "Q")