#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [Alias('Sample', 'Project')]
    [ValidateNotNullOrEmpty()]
    [string] $Target = 'school',
    [string] $MainFile,
    [ValidateSet('uplatex', 'platex', 'lualatex', 'pdflatex', 'xelatex')]
    [string] $Engine,
    [switch] $Clean
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$examples = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $PSScriptRoot 'examples.json') |
    ConvertFrom-Json
$example = $examples.PSObject.Properties[$Target]
if ($example) {
    $projectDirectory = Join-Path $repositoryRoot $example.Value.directory
    if (!$MainFile) { $MainFile = $example.Value.main }
} elseif ([IO.Path]::IsPathRooted($Target)) {
    $projectDirectory = $Target
} else {
    $projectDirectory = Join-Path $repositoryRoot $Target
}
$projectDirectory = (Get-Item -LiteralPath $projectDirectory -ErrorAction Stop).FullName
if (!$MainFile) {
    if (Test-Path -LiteralPath (Join-Path $projectDirectory 'main.tex')) {
        $MainFile = 'main.tex'
    } else {
        $rootFiles = @(Get-ChildItem -LiteralPath $projectDirectory -File -Filter '*.tex')
        if ($rootFiles.Count -ne 1) {
            throw 'Specify -MainFile when the folder has zero or multiple root TeX files.'
        }
        $MainFile = $rootFiles[0].Name
    }
}
$texPath = Join-Path $projectDirectory $MainFile
$rcPath = Join-Path $projectDirectory '.latexmkrc'
if (!(Test-Path -LiteralPath $texPath -PathType Leaf)) { throw "Missing TeX source: $texPath" }
if (!(Test-Path -LiteralPath $rcPath -PathType Leaf)) { throw "Missing project settings: $rcPath" }
Get-Command latexmk -ErrorAction Stop | Out-Null
$arguments = @('-norc', '-r', $rcPath, '-cd')
if ($Clean) { $arguments += '-c' }
$arguments += $texPath

$previousPerl = [Environment]::GetEnvironmentVariable('TEXLIVE_WINDOWS_TRY_EXTERNAL_PERL', 'Process')
$previousEngine = [Environment]::GetEnvironmentVariable('LATEX_ENGINE', 'Process')
try {
    # TeX Live ignores this variable on other operating systems.
    $env:TEXLIVE_WINDOWS_TRY_EXTERNAL_PERL = '0'
    if ($Engine) { $env:LATEX_ENGINE = $Engine }
    & latexmk @arguments
    if ($LASTEXITCODE -ne 0) { throw "LaTeX build failed (exit $LASTEXITCODE)." }
} finally {
    if ($null -eq $previousPerl) {
        Remove-Item -LiteralPath Env:TEXLIVE_WINDOWS_TRY_EXTERNAL_PERL -ErrorAction SilentlyContinue
    } else {
        [Environment]::SetEnvironmentVariable('TEXLIVE_WINDOWS_TRY_EXTERNAL_PERL', $previousPerl, 'Process')
    }
    if ($null -eq $previousEngine) {
        Remove-Item -LiteralPath Env:LATEX_ENGINE -ErrorAction SilentlyContinue
    } else {
        [Environment]::SetEnvironmentVariable('LATEX_ENGINE', $previousEngine, 'Process')
    }
}
