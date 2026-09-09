[CmdletBinding()]
param(
    [string]$Repository = "",
    [string]$GitUserName = "520pt",
    [string]$GitUserEmail = "520pt@users.noreply.github.com"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($GitUserName) -or [string]::IsNullOrWhiteSpace($GitUserEmail)) {
    throw "Git 提交者名称和邮箱不能为空。"
}

if ([string]::IsNullOrWhiteSpace($Repository)) {
    $Repository = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

if (-not (Test-Path -LiteralPath (Join-Path $Repository ".git"))) {
    throw "不是 Git 仓库：$Repository"
}

git -C $Repository config core.hooksPath .githooks
if ($LASTEXITCODE -ne 0) {
    throw "启用 Git 自动推送钩子失败。"
}

git -C $Repository config user.name $GitUserName
if ($LASTEXITCODE -ne 0) {
    throw "配置 Git 提交者名称失败。"
}

git -C $Repository config user.email $GitUserEmail
if ($LASTEXITCODE -ne 0) {
    throw "配置 Git 提交者邮箱失败。"
}

Write-Output "已启用 Git 自动推送钩子：$Repository"
