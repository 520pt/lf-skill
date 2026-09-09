[CmdletBinding()]
param(
    [string]$Repository = "",
    [string]$Message = "Update lufei-lessons"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ([string]::IsNullOrWhiteSpace($Repository)) {
    $Repository = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

if (-not (Test-Path -LiteralPath (Join-Path $Repository ".git"))) {
    throw "不是 Git 仓库：$Repository"
}

$status = @(git -C $Repository status --short)
if ($status.Count -eq 0) {
    Write-Output "没有需要同步的公开文件。"
    exit 0
}

Write-Output "即将提交以下变更："
$status | ForEach-Object { Write-Output $_ }

git -C $Repository add -A
git -C $Repository diff --cached --check

git -C $Repository diff --cached --name-only | ForEach-Object {
    if ($_ -match '(^|/)(lesson-log\.md|.*\.private\.md|.*\.local\.md)$') {
        throw "检测到不应公开的私有文件：$_"
    }
}

git -C $Repository commit -m $Message
git -C $Repository push origin HEAD
Write-Output "已提交并推送到 GitHub。"
