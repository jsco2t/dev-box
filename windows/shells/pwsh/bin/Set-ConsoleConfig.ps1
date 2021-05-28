param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [int]
    $ConsoleWidth = 200,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [int]
    $ConsoleHeight = 90,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [int]
    $ConsoleFontSize = 18,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [int]
    $PositionX = 0,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [int]
    $PositionY = 0
)
$console = $host.UI.RawUI

Add-Type -ReferencedAssemblies 'System.Runtime.dll' -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class ConsoleHelper
{
    private const int FixedWidthTrueType = 54;
    private const int StandardOutputHandle = -11;

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern IntPtr GetStdHandle(int nStdHandle);

    [return: MarshalAs(UnmanagedType.Bool)]
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    internal static extern bool SetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool MaximumWindow, ref FontInfo ConsoleCurrentFontEx);

    [return: MarshalAs(UnmanagedType.Bool)]
    [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    internal static extern bool GetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool MaximumWindow, ref FontInfo ConsoleCurrentFontEx);

    private static readonly IntPtr ConsoleOutputHandle = GetStdHandle(StandardOutputHandle);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct FontInfo
    {
        internal int cbSize;
        internal int FontIndex;
        internal short FontWidth;
        public short FontSize;
        public int FontFamily;
        public int FontWeight;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        //[MarshalAs(UnmanagedType.ByValArray, ArraySubType = UnmanagedType.wc, SizeConst = 32)]
        public string FontName;
    }

    public static FontInfo[] SetCurrentFont(string font, short fontSize = 0)
    {
        Console.WriteLine("Set Current Font: " + font);

        FontInfo before = new FontInfo
        {
            cbSize = Marshal.SizeOf<FontInfo>()
        };

        if (GetCurrentConsoleFontEx(ConsoleOutputHandle, false, ref before))
        {

            FontInfo set = new FontInfo
            {
                cbSize = Marshal.SizeOf<FontInfo>(),
                FontIndex = 0,
                FontFamily = FixedWidthTrueType,
                FontName = font,
                FontWeight = 400,
                FontSize = fontSize > 0 ? fontSize : before.FontSize
            };

            // Get some settings from current font.
            if (!SetCurrentConsoleFontEx(ConsoleOutputHandle, false, ref set))
            {
                var ex = Marshal.GetLastWin32Error();
                Console.WriteLine("Set error " + ex);
                throw new System.ComponentModel.Win32Exception(ex);
            }

            FontInfo after = new FontInfo
            {
                cbSize = Marshal.SizeOf<FontInfo>()
            };
            GetCurrentConsoleFontEx(ConsoleOutputHandle, false, ref after);

            return new[] { before, set, after };
        }
        else
        {
            var er = Marshal.GetLastWin32Error();
            Console.WriteLine("Get error " + er);
            throw new System.ComponentModel.Win32Exception(er);
        }
    }
}

public class Window
{
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out Rect lpRect);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public extern static bool MoveWindow(IntPtr handle, int x, int y, int width, int height, bool redraw);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ShowWindow(IntPtr handle, int state);
}

public struct Rect
{
    public int Left;        // x position of upper-left corner
    public int Top;         // y position of upper-left corner
    public int Right;       // x position of lower-right corner
    public int Bottom;      // y position of lower-right corner
}

'@

#
# Internal Functions
#
function Get-CurrentWindowHandle {
    param(
        [Parameter(Mandatory = $false)]
        [int]
        $CurrentPid
    )

    if ($null -eq $CurrentPid -or 0 -eq $CurrentPid) {
        $CurrentPid = $PID
    }

    Write-Host ""
    Write-Host "Current process id is: $CurrentPid"

    $result = (Get-Process -Id $CurrentPid).MainWindowHandle
    Write-Host "Current window handle: $result"

    return $result
}

function Set-WindowPosition {
    param(
        [Parameter(Mandatory = $true)]
        [int]
        $X,

        [Parameter(Mandatory = $true)]
        [int]
        $Y,

        [Parameter(Mandatory = $true)]
        [int]
        $WindowHandle
    )

    $rectangle = New-Object Rect


    #
    # Log Parameters
    #
    Write-Host ""
    Write-Host "###################################################################"
    Write-Host "Set-WindowPosition Parameters:"
    Write-Host "  X: $X"
    Write-Host "  Y: $Y"
    Write-Host "  WindowHandle: $WindowHandle"
    Write-Host "###################################################################"

    Write-Host ""
    Write-Host "Getting current window position..."

    $rectangle = New-Object Rect
    [Window]::GetWindowRect($WindowHandle, [ref]$rectangle)
    $height = $rectangle.Bottom - $rectangle.Top
    $width = $rectangle.Right - $rectangle.Left

    Write-Host "Current window position (x/y): $($rectangle.Left)/$($rectangle.Top)"

    Write-Host "Setting window position to: $X/$Y"
    [Window]::MoveWindow($WindowHandle, $X, $Y, $width, $height, $True)
}

#
# Log Parameters
#
Write-Host ""
Write-Host "###################################################################"
Write-Host "Set-ConsoleConfig Parameters:"
Write-Host "  ConsoleWidth: $ConsoleWidth"
Write-Host "  ConsoleHeight: $ConsoleHeight"
Write-Host "  ConsoleFontSize: $ConsoleFontSize"
Write-Host "  PositionX: $PositionX"
Write-Host "  PositionY: $PositionY"
Write-Host "###################################################################"

Write-Host "Setting console font"
[ConsoleHelper]::SetCurrentFont("Consolas", $ConsoleFontSize) | Out-Null

Write-Host "Calculating console max height"
if ($ConsoleHeight -gt $console.MaxWindowSize.Height)
{
    $ConsoleHeight = $console.MaxWindowSize.Height - 2
}

Write-Host "Setting console width/height ($ConsoleWidth/$ConsoleHeight)"
$buffer = $console.BufferSize
$buffer.Width = $ConsoleWidth
$buffer.Height = 9999 #$($ConsoleHeight * 10)
$console.BufferSize = $buffer

$size = $console.WindowSize
$size.Width = $ConsoleWidth
$size.Height = $ConsoleHeight
$console.WindowSize = $size

Write-Host "Setting window posistion to: $PositionX/$PositionY"
$windowHandle = Get-CurrentWindowHandle
Set-WindowPosition -X $PositionX -Y $PositionY -WindowHandle $windowHandle

Write-Host ""
Write-Host ""