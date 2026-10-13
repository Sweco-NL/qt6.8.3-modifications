<#
.SYNOPSIS
Fetches source and builds 32bit Version of Qt6 6.8.3

.DESCRIPTION
Debug and Release builds for 32bit without WebEngine. 

.EXAMPLE
powershell -ExecutionPolicy Bypass -File "built_qt6_x86.ps1"
#>

# Set strict mode and stop on errors where appropriate
$ErrorActionPreference = "Continue"


function Resolve-VsInstallRoot {
    $vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path $vsWhere)) {
        throw "vswhere.exe was not found."
    }

    $installationPath = & $vsWhere -latest -version "[17.0,18.0)" -property installationPath
    if ($LASTEXITCODE -ne 0 -or -not $installationPath) {
        throw "Visual Studio 2022 installation was not found."
    }

    return $installationPath
}

function Resolve-VsInitScript {
    $installationPath = Resolve-VsInstallRoot
    $vsInitScript = Join-Path $installationPath "Common7\Tools\Launch-VsDevShell.ps1"
    if (Test-Path $vsInitScript) {
        return $vsInitScript
    }

    throw "Launch-VsDevShell.ps1 was not found: $vsInitScript"
}

function Test-Dependency {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $false)]
        [string[]]$Arguments = @(),

        [Parameter(Mandatory = $true)]
        [string]$ErrorMessage,

        [switch]$ShowOutput
    )

    Write-Host "Checking $Name..."

    try {
        if (-not (Get-Command $Command -ErrorAction Stop)) {
            throw "$Command was not found"
        }

        $output = & $Command @Arguments 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "$Command returned exit code $LASTEXITCODE"
        }

        Write-Host "[OK] $Name is available"
        if ($ShowOutput) {
            Write-Host $output
        }

        return $true
    } catch {
        Write-Host "[ERROR] $ErrorMessage"
        return $false
    }
}

function Test-Dependencies {

    Write-Host "Checking dependencies for Qt6 build..." -ForegroundColor Green
    Write-Host "====================================="
    $DEPENDENCIES_OK = $true

    # --- Check dependencies ---
    $DEPENDENCIES_OK = Test-Dependency `
        -Name "git" `
        -Command "git" `
        -Arguments @("--version") `
        -ErrorMessage "Git is not installed or not in PATH" `
        -ShowOutput
    Write-Host ""

    $DEPENDENCIES_OK = (Test-Dependency `
        -Name "Python" `
        -Command "python" `
        -Arguments @("--version") `
        -ErrorMessage "Python is not installed or not in PATH" `
        -ShowOutput) -and $DEPENDENCIES_OK

    if ($DEPENDENCIES_OK) {
        $DEPENDENCIES_OK = (Test-Dependency `
            -Name "html5lib" `
            -Command "python" `
            -Arguments @("-c", "import html5lib") `
            -ErrorMessage "html5lib is not installed. Install with: pip install html5lib") -and $DEPENDENCIES_OK
    }

    if (-not $DEPENDENCIES_OK) {
        Write-Host "[FATAL] One or more dependencies are missing. Please install them before proceeding."
        Write-Host "Required dependencies:"
        Write-Host "  - Python (with html5lib): pip install html5lib"
        exit 1
    }
    Write-Host "[SUCCESS] All dependencies are available!"

}

function Init-VS-Env {
    Write-Host "Proceeding with setting up VS build env..."
    $script:VsInitScript = Resolve-VsInitScript
    & $script:VsInitScript -Arch  "x86" -HostArch amd64
    Write-Host "[OK] VS environment loaded."
} 

function Get-Source{
    # --- Qt Source ---
    Write-Host "Qt Source dir: $script:QtSourceDir" -ForegroundColor Green

    if (Test-Path $script:QtSourceDir) {
        Write-Host "Qt source directory already exists, skipping clone..."
    } else {
        Write-Host "Cloning Qt6 source into qt6_source..."
        New-Item -ItemType Directory -Path $script:QtSourceDir | Out-Null
        Push-Location $script:QtSourceDir
        & git clone --branch v6.8.3 "https://code.qt.io/qt/qt5.git" .
        Pop-Location
    }
}

function Configure-Build {
    # --- Build Directory & Configure ---

    if (-not (Test-Path $script:BuildDir)) {
        Write-Host "Creating build dir: $script:BuildDir"
        New-Item -ItemType Directory -Path $script:BuildDir | Out-Null
    }

    Set-Location $script:BuildDir
    Write-Host "Configuration: Without WebViewer (debug + release)" -ForegroundColor Green

    # Run configure:
    & "$script:QtSourceDir\configure.bat" `
        -init-submodules `
        -debug-and-release `
        -submodules qtbase,qttools,qt5compat,qtserialport,qtwebsockets `
        -prefix $script:InstallDir
    if ($LASTEXITCODE -ne 0) { throw "configure failed with exit code $LASTEXITCODE" }  


    Write-Host "Configuration: done" -ForegroundColor Green
    Write-Host ("[TIME] {0}" -f $script:timer.Elapsed)
} 

function Run-Build {
    # --- Build ---
    Write-Host "====================================="
    Write-Host "Running Build..."
    Set-Location $script:BuildDir
    & cmake --build . --parallel

    Write-Host "====================================="
    Write-Host "Build complete."
    Write-Host ("[TIME] {0}" -f $script:timer.Elapsed)
    Set-Location $script:BuildDir

}

function Install-Build {
    if (-not (Test-Path $script:InstallDir)) {
        Write-Host "Creating Install dir: $script:InstallDir"
        New-Item -ItemType Directory -Path $script:InstallDir | Out-Null
    }

    Write-Host "Installing into $script:InstallDir"
    Set-Location $script:BuildDir
    & ninja install

    Set-Location $script:ScriptDir
}

# ======  Build script starts from here ====== 
$script:ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$script:QtSourceDir = Join-Path $script:ScriptDir "qt6_source"
$script:BuildDir = Join-Path $script:ScriptDir "qb"
$script:InstallDir = Join-Path $script:ScriptDir "qt6_install_x86"
$script:timer = [System.Diagnostics.Stopwatch]::StartNew()
Test-Dependencies 
Init-VS-Env
Get-Source
Configure-Build
Run-Build
Install-Build
Write-Host ("[TIME] {0}" -f $script:timer.Elapsed)
