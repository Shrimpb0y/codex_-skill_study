[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Chapter,

    [Parameter(Mandatory = $true)]
    [string]$Workspace,

    [string]$NodePath,

    [string]$MarkmapCliPath
)

$ErrorActionPreference = 'Stop'

$chapterName = [System.IO.Path]::GetFileNameWithoutExtension($Chapter)
if ($chapterName -notmatch '^[A-Za-z0-9_-]+$' -or $Chapter -match '[\\/]' -or $Chapter.Contains('..')) {
    throw "Invalid chapter name '$Chapter'. Use a simple name such as chap3."
}

$workspacePath = (Resolve-Path -LiteralPath $Workspace).Path
$markdownPath = Join-Path $workspacePath "$chapterName.md"
$htmlPath = Join-Path $workspacePath "$chapterName.html"

if (-not (Test-Path -LiteralPath $markdownPath -PathType Leaf)) {
    throw "Markdown input not found: $markdownPath"
}

if (-not $NodePath) {
    $nodeCommand = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCommand) {
        $NodePath = $nodeCommand.Source
    }
}

if (-not $NodePath -or -not (Test-Path -LiteralPath $NodePath -PathType Leaf)) {
    throw 'Node.js was not found. Pass -NodePath using the bundled workspace dependency path.'
}

if (-not $MarkmapCliPath) {
    $candidates = @(
        (Join-Path $workspacePath 'markmap-site\node_modules\markmap-cli\bin\cli.js'),
        (Join-Path $workspacePath 'node_modules\markmap-cli\bin\cli.js')
    )
    $MarkmapCliPath = $candidates | Where-Object {
        Test-Path -LiteralPath $_ -PathType Leaf
    } | Select-Object -First 1
}

if (-not $MarkmapCliPath -or -not (Test-Path -LiteralPath $MarkmapCliPath -PathType Leaf)) {
    throw "Local markmap-cli was not found under '$workspacePath\markmap-site\node_modules' or '$workspacePath\node_modules'."
}

& $NodePath $MarkmapCliPath $markdownPath '--offline' '--no-open' '-o' $htmlPath
if ($LASTEXITCODE -ne 0) {
    throw "markmap-cli failed with exit code $LASTEXITCODE."
}

if (-not (Test-Path -LiteralPath $htmlPath -PathType Leaf)) {
    throw "Markmap output was not created: $htmlPath"
}

$html = Get-Content -LiteralPath $htmlPath -Raw
$externalScriptCount = ([regex]::Matches($html, '<script[^>]+src=["'']https?://')).Count
$checks = [ordered]@{
    HasMarkdown = (Test-Path -LiteralPath $markdownPath -PathType Leaf)
    HasHtml = ((Get-Item -LiteralPath $htmlPath).Length -gt 0)
    HasMarkmap = $html.Contains('Markmap.create')
    HasSvg = $html.Contains('<svg')
    ExternalScriptCount = $externalScriptCount
}

if (-not $checks.HasMarkmap -or -not $checks.HasSvg -or $externalScriptCount -ne 0) {
    throw "Generated HTML failed offline validation: $($checks | ConvertTo-Json -Compress)"
}

[pscustomobject]@{
    Chapter = $chapterName
    Markdown = $markdownPath
    Html = $htmlPath
    HtmlBytes = (Get-Item -LiteralPath $htmlPath).Length
    Offline = $true
}
