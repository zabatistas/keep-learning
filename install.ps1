<#
.SYNOPSIS
  Windows entry point for the Vibe-Learn installer.

.DESCRIPTION
  Runs install.sh through Git for Windows' bash. Plain `bash` from PowerShell usually
  launches WSL instead, which installs into the Linux home directory rather than the
  Windows one that Antigravity, Claude Code and Cursor read.

  All arguments are passed through to install.sh, e.g.:
    .\install.ps1
    .\install.ps1 --claude-code
    .\install.ps1 --hub-dir C:\Users\me\my-learnings --cursor-repo C:\code\my-service
#>
$ErrorActionPreference = 'Stop'

function Find-GitBash {
    $candidates = @()
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        # ...\Git\cmd\git.exe or ...\Git\bin\git.exe -> ...\Git\bin\bash.exe
        $gitRoot = Split-Path (Split-Path $git.Source -Parent) -Parent
        $candidates += Join-Path $gitRoot 'bin\bash.exe'
    }
    foreach ($base in @($env:ProgramFiles, ${env:ProgramFiles(x86)}, (Join-Path $env:LOCALAPPDATA 'Programs'))) {
        if ($base) { $candidates += Join-Path $base 'Git\bin\bash.exe' }
    }
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    return $null
}

$bash = Find-GitBash
if (-not $bash) {
    Write-Error "Git Bash not found. Install Git for Windows (https://git-scm.com/download/win) and run this script again."
    exit 1
}

$installer = Join-Path $PSScriptRoot 'install.sh'
& $bash $installer @args
exit $LASTEXITCODE
