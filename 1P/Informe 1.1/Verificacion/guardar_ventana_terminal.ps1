param([Parameter(Mandatory=$true)][int]$ProcesoTerminal,
      [Parameter(Mandatory=$true)][string]$Destino)
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class TerminalScreenshotBounds {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern IntPtr SetThreadDpiAwarenessContext(IntPtr context);
    [DllImport("dwmapi.dll")]
    public static extern int DwmGetWindowAttribute(IntPtr hWnd, int attribute, out RECT rect, int size);
}
'@
$taskTerminal=Get-Process -Id $ProcesoTerminal -ErrorAction Stop
if($taskTerminal.ProcessName -ne 'WindowsTerminal') { throw 'El proceso no es Windows Terminal.' }
if($taskTerminal.MainWindowTitle -ne 'Windows PowerShell') { throw 'La ventana no corresponde a la terminal de la consulta.' }
$taskHandle=$taskTerminal.MainWindowHandle
if(-not [TerminalScreenshotBounds]::IsWindowVisible($taskHandle)) { throw 'La ventana no es visible.' }
if([TerminalScreenshotBounds]::GetForegroundWindow() -ne $taskHandle) { throw 'La terminal no esta al frente; no se guardara una captura de otra ventana.' }
$taskRect=New-Object TerminalScreenshotBounds+RECT
[void][TerminalScreenshotBounds]::SetThreadDpiAwarenessContext([IntPtr](-4))
if([TerminalScreenshotBounds]::DwmGetWindowAttribute($taskHandle,9,[ref]$taskRect,16) -ne 0) { throw 'No se pudieron leer los limites de la ventana.' }
$taskBitmap=New-Object System.Drawing.Bitmap(($taskRect.Right-$taskRect.Left),($taskRect.Bottom-$taskRect.Top))
$taskGraphics=[System.Drawing.Graphics]::FromImage($taskBitmap)
try {
    $taskGraphics.CopyFromScreen($taskRect.Left,$taskRect.Top,0,0,$taskBitmap.Size)
    $taskBitmap.Save($Destino,[System.Drawing.Imaging.ImageFormat]::Png)
    [pscustomobject]@{Titulo=$taskTerminal.MainWindowTitle;Archivo=$Destino;Ancho=$taskBitmap.Width;Alto=$taskBitmap.Height}
} finally { $taskGraphics.Dispose();$taskBitmap.Dispose() }
