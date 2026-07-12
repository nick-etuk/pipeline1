$P1_VERSION = '2.0'  # Update this when making changes that require users to update their profiles

$P1_USER_WIN = $env:USERNAME
$P1_USER_UNIX = $P1_USER_WIN.ToLower()
# if ($DEBUG) { $P1_USER_UNIX = "account1" }
$P1_USER_UNIX = "account1"
$P1_ROOT_UNIX = ''
$VM = ''

$BASE_DIR = "$HOME\.pipeline1"
$WORKING_DIR = "$BASE_DIR\working"
$LOG_BASE="$BASE_DIR\log" #todo: use windows event log, C:\WINDOWS\system32\config
$MY_DOWNLOAD_DIR = "$BASE_DIR\downloads"

$TICK_MARK = "$([char]0x1b)[92m$([char]8730)"
$CROSS_MARK = "$([char]0x1b)[91m$([char]10006)"

$GreenCheck = @{
    Object = [Char]8730
    ForegroundColor = 'Green'
    NoNewLine = $true
}

$RedCross = @{
    Object = [Char]10006
    ForegroundColor = 'Red'
    NoNewLine = $true
}

$NoColor = @{
    Object = 'a'
    ForegroundColor = 'White'
    NoNewLine = $true
}

# Todo: NHS App project configuration. Move these out of built-in config.
# $ANDROID_SDK_ROOT = 'C:\app\android_sdk'
$ANDROID_EMULATOR_PORT = '5554'
$ANDROID_DEFAULT_DEVICE='Pixel_10_API_37_Google_APIs'
$LOGINENV = 'sandpit'

$NODE_MAJOR_VERSION = '22'
$DOTNET_MAJOR_VERSION = '10'
$PYTHON_MAJOR_VERSION = '3'
$PYTHON_MINOR_VERSION = '9'
