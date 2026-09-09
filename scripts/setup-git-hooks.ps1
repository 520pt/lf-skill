[CmdletBinding()]
param(
    [string]$Repository = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($Repository)) {
    $Repository = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

if (-not (Test-Path -LiteralPath (Join-Path $Repository ".git"))) {
    throw "不是 Git 仓库：$Repository"
}

git -C $Repository config core.hooksPath .githooks
Write-Output "已启用 Git 自动推送钩子：$Repository"
