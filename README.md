# NVIDIA 4090/5090 GPU Freeze Fix (Windows 11)

A PowerShell utility to fix the 5-6 second "stutter" or "freeze" often experienced on high-end NVIDIA GPUs (RTX 4090 / 5090) when using Windows 11. 

This script manages the **TDR Delay** and **MPO (Multi-Plane Overlay)** registry keys to prevent driver timeouts and overlay conflicts.

## 🚀 Features

* **Status Check:** Instantly view if your registry keys are set to "Performance" or "Default".
* **TDR Delay Fix:** Increases the *Timeout Detection and Recovery* delay from 2s to **10s**, preventing Windows from resetting the GPU driver during heavy loads.
* **MPO Disable:** Disables *Multi-Plane Overlay* to fix conflicts with the NVIDIA Overlay, Discord, and other 2D elements.
* **Safe Revert:** Includes options to remove keys and return Windows to stock behavior.

## 📋 Prerequisites

* **OS:** Windows 10 or Windows 11
* **Permissions:** Must be run as **Administrator** (Script will self-elevate if needed).
* **Hardware:** Optimized for NVIDIA RTX 3000/4000/5000 series, but works on any dedicated GPU.

## 🛠️ Installation & Usage

1.  **Clone the repository:**
    ```powershell
    git clone [https://github.com/javasavvydev/Windows11_4090_5090_GPU_Fix.git](https://github.com/javasavvydev/Windows11_4090_5090_GPU_Fix.git)
    cd Windows11_4090_5090_GPU_Fix
    ```

2.  **Run the script:**
    Right-click `FixGPU.ps1` and select **Run with PowerShell**, or run it from your terminal:
    ```powershell
    .\FixGPU.ps1
    ```

3.  **Select an Option:**
    * **[A] Apply ALL Fixes:** Recommended for most users. Sets TDR to 10s and disables MPO.
    * **[T] Apply TDR Delay Only:** Use this if you only want to stop the driver resets but keep MPO enabled.
    * **[R] Revert:** Removes all registry keys created by this script.

4.  **Reboot:**
    You **must restart your computer** for these registry changes to take effect.

## ⚙️ Technical Details

This script modifies the following registry keys:

| Feature | Registry Path | Key | Value |
| :--- | :--- | :--- | :--- |
| **TDR Delay** | `HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers` | `TdrDelay` | `10` (Decimal) |
| **MPO Disable** | `HKLM\SOFTWARE\Microsoft\Windows\Dwm` | `OverlayTestMode` | `5` (DWORD) |

## ⚠️ Disclaimer

**Use at your own risk.** This script modifies the Windows Registry. While these are documented Microsoft/NVIDIA troubleshooting steps, editing the registry always carries a small risk. 
* Always ensure your data is backed up.
* This software is provided "as is", without warranty of any kind.

---
*Created by [JavaSavvyDev](https://github.com/javasavvydev)*