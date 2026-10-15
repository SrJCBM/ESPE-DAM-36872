param([ValidateSet('01','02','03','04','07','09','10','11')][string]$Figura='04')
$ErrorActionPreference = 'Stop'
$OutputEncoding = [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$taskTerminalFolder = $PSScriptRoot
$taskReadyFile = Join-Path $taskTerminalFolder ('terminal_' + $Figura + '_lista.txt')
$Host.UI.RawUI.WindowTitle = 'Windows PowerShell'
Clear-Host
function Consulta([string]$Texto, [scriptblock]$Accion) {
    Write-Host ('Comando: ' + $Texto) -ForegroundColor Cyan
    & $Accion
    Write-Host ''
}
try {
    switch ($Figura) {
        '01' {
            Consulta 'Get-CimInstance Win32_OperatingSystem / Win32_Processor / Win32_LogicalDisk' {
                $taskOs=Get-CimInstance Win32_OperatingSystem
                $taskCpu=Get-CimInstance Win32_Processor | Select-Object -First 1
                $taskDisk=Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
                [pscustomobject]@{Sistema=$taskOs.Caption;Version=$taskOs.Version;Arquitectura=$taskOs.OSArchitecture;Procesador=$taskCpu.Name;RAM_GB=[Math]::Round($taskOs.TotalVisibleMemorySize/1MB,2);Disco_C_libre_GB=[Math]::Round($taskDisk.FreeSpace/1GB,2)} | Format-List | Out-Host
            }
            Consulta 'git --version' { git --version }
        }
        '02' {
            Consulta 'Get-ChildItem C:\Users\jcbla\flutter\flutter -Directory | Select-Object Mode,Name' {
                Get-ChildItem -LiteralPath 'C:\Users\jcbla\flutter\flutter' -Directory | Select-Object Mode,Name | Format-Table -AutoSize | Out-Host
            }
        }
        '03' {
            Consulta "[Environment]::GetEnvironmentVariable('Path','User') -split ';' | Where-Object { `$_ -match 'flutter' }" {
                [Environment]::GetEnvironmentVariable('Path','User') -split ';' | Where-Object { $_ -match 'flutter' }
            }
            Consulta 'where.exe flutter' { where.exe flutter }
            Consulta 'Get-Command flutter | Select-Object Name,Source' {
                Get-Command flutter | Select-Object Name,Source | Format-List | Out-Host
            }
        }
        '04' {
            Consulta 'flutter --version' { flutter --version }
            Consulta 'dart --version' { dart --version }
            Consulta 'git --version' { git --version }
            Consulta 'where.exe flutter' { where.exe flutter }
        }
        '07' {
            $env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
            $taskSdkManager=Join-Path $env:LOCALAPPDATA 'Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat'
            Write-Host ('SDK: ' + (Join-Path $env:LOCALAPPDATA 'Android\Sdk'))
            Consulta 'sdkmanager --list_installed (columnas Paquete y Version)' {
                & $taskSdkManager --list_installed | Where-Object { $_ -match '^\s*[^|]+\|[^|]+\|' -and $_ -notmatch 'Description|-------' } | ForEach-Object {
                    $taskParts=$_ -split '\|'
                    [pscustomobject]@{Paquete=$taskParts[0].Trim();Version=$taskParts[1].Trim()}
                } | Format-Table -AutoSize | Out-Host
            }
        }
        '09' {
            Consulta 'flutter doctor --android-licenses' { flutter doctor --android-licenses }
        }
        '10' {
            Consulta 'flutter doctor' { flutter doctor }
        }
        '11' {
            Consulta 'flutter emulators | Select-String "available emulator|Id |Pixel_"' {
                flutter emulators | Select-String 'available emulator|Id |Pixel_' | ForEach-Object { $_.Line }
            }
            Consulta 'flutter devices | Select-String "connected devices|android-x64|Windows \(desktop\)|Chrome \(web\)"' {
                flutter devices | Select-String 'connected devices|android-x64|Windows \(desktop\)|Chrome \(web\)' | ForEach-Object { $_.Line }
            }
            Consulta 'emulator -accel-check' {
                & (Join-Path $env:LOCALAPPDATA 'Android\Sdk\emulator\emulator.exe') -accel-check
            }
        }
    }
    'Comandos finalizados.' | Set-Content -LiteralPath $taskReadyFile -Encoding UTF8
} catch {
    Write-Host $_ -ForegroundColor Red
    $_.Exception.Message | Set-Content -LiteralPath $taskReadyFile -Encoding UTF8
}
