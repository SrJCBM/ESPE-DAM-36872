param([string[]]$Figuras=@('01','02','03','04','07','09','10','11'))
$ErrorActionPreference='Stop'
$taskCaptureRoot=Split-Path -Parent $PSScriptRoot
$taskPhotoRoot=Join-Path $taskCaptureRoot 'Fotos_Overleaf'
$taskConsoleScript=Join-Path $PSScriptRoot 'capturar_terminal.ps1'
$taskCaptureScript=Join-Path $PSScriptRoot 'guardar_ventana_terminal.ps1'
$taskCaptureMap=[ordered]@{
    '01'='figura01_requisitos.png'
    '02'='figura02_flutter_sdk.png'
    '03'='figura03_path.png'
    '04'='figura04_versiones.png'
    '07'='figura07_android_sdk.png'
    '09'='figura09_licencias.png'
    '10'='figura10_doctor.png'
    '11'='figura11_dispositivo.png'
}
foreach($taskFigure in ($taskCaptureMap.Keys | Where-Object { $Figuras -contains $_ })) {
    $taskLaunchTime=Get-Date
    $taskReadyFile=Join-Path $PSScriptRoot ('terminal_'+$taskFigure+'_lista.txt')
    & wt.exe -w new --size 90,30 powershell.exe -NoLogo -NoProfile -NoExit -File $taskConsoleScript -Figura $taskFigure
    $taskCaptureDeadline=(Get-Date).AddSeconds(45)
    $taskTerminalCandidate=$null
    do {
        Start-Sleep -Milliseconds 500
        $taskTerminalCandidates=@()
        if((Test-Path -LiteralPath $taskReadyFile) -and (Get-Item -LiteralPath $taskReadyFile).LastWriteTime -gt $taskLaunchTime) {
            if((Get-Content -LiteralPath $taskReadyFile -Raw).Trim() -ne 'Comandos finalizados.') { throw (Get-Content -LiteralPath $taskReadyFile -Raw) }
            $taskTerminalCandidates=@(Get-Process -Name WindowsTerminal -ErrorAction SilentlyContinue | Where-Object MainWindowTitle -EQ 'Windows PowerShell')
        }
        if($taskTerminalCandidates.Count -gt 1) { throw 'Hay mas de una ventana que corresponde a la consulta.' }
        if($taskTerminalCandidates.Count -eq 1) { $taskTerminalCandidate=$taskTerminalCandidates[0] }
    } while(-not $taskTerminalCandidate -and (Get-Date) -lt $taskCaptureDeadline)
    if(-not $taskTerminalCandidate) { throw ('No finalizo la consulta para la figura '+$taskFigure) }
    & wt.exe -w 0 focus-tab -t 0
    Start-Sleep -Milliseconds 300
    & $taskCaptureScript -ProcesoTerminal $taskTerminalCandidate.Id -Destino (Join-Path $taskPhotoRoot $taskCaptureMap[$taskFigure])
    $taskConsoleProcesses=Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | Where-Object { $_.CommandLine -like ('*"'+$taskConsoleScript+'"*') -and $_.CommandLine -match ('-Figura\s+'+$taskFigure+'(?:\s|$)') }
    foreach($taskConsoleProcess in $taskConsoleProcesses) { Stop-Process -Id $taskConsoleProcess.ProcessId }
    Start-Sleep -Milliseconds 500
}
