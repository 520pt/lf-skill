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
if ($LASTEXITCODE -ne 0) {
    throw "Git 暂存文件失败。"
}

git -C $Repository diff --cached --check
if ($LASTEXITCODE -ne 0) {
    throw "Git 差异检查失败，请先修复空白字符或换行问题。"
}

git -C $Repository diff --cached --name-only | ForEach-Object {
    if ($_ -match '(^|/)(lesson-log\.md|.*\.private\.md|.*\.local\.md)$') {
        throw "检测到不应公开的私有文件：$_"
    }
}

git -C $Repository -c core.hooksPath= commit -m $Message
if ($LASTEXITCODE -ne 0) {
    throw "Git 提交失败。"
}

$oldGitTerminalPrompt = $env:GIT_TERMINAL_PROMPT
$env:GIT_TERMINAL_PROMPT = "0"
try {
    git -C $Repository `
        -c credential.interactive=never `
        -c http.version=HTTP/1.1 `
        -c http.lowSpeedLimit=1 `
        -c http.lowSpeedTime=15 `
        push origin HEAD
    if ($LASTEXITCODE -ne 0) {
        throw "GitHub 推送失败。已保留本地提交，请检查 GitHub 登录状态和网络。"
    }
} finally {
    $env:GIT_TERMINAL_PROMPT = $oldGitTerminalPrompt
}

Write-Output "已提交并推送到 GitHub。"
