[CmdletBinding()]
param(
    [string]$RepoUrl = "https://github.com/520pt/lf-skill.git",
    [string]$CodexHome = "",
    [string]$GitUserName = "520pt",
    [string]$GitUserEmail = "520pt@users.noreply.github.com",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "未找到 Git。请先安装 Git for Windows，再重新运行此脚本。"
}

if ([string]::IsNullOrWhiteSpace($GitUserName) -or [string]::IsNullOrWhiteSpace($GitUserEmail)) {
    throw "Git 提交者名称和邮箱不能为空。"
}

function Assert-GitSucceeded {
    param(
        [string]$Action
    )

    if ($LASTEXITCODE -ne 0) {
        throw "Git 操作失败：$Action。退出码：$LASTEXITCODE"
    }
}

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $CodexHome = $env:CODEX_HOME
    } else {
        $CodexHome = Join-Path $HOME ".codex"
    }
}

$skillsDir = Join-Path $CodexHome "skills"
$target = Join-Path $skillsDir "lufei-lessons"
New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

if (Test-Path -LiteralPath $target) {
    $isRepo = git -C $target rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -eq 0 -and $isRepo -eq "true") {
        $origin = git -C $target remote get-url origin 2>$null
        if ($LASTEXITCODE -ne 0 -or $origin -ne $RepoUrl) {
            throw "目标目录已经是其他 Git 仓库：$target。为避免覆盖，脚本已停止。"
        }
        git -C $target pull --ff-only
        Assert-GitSucceeded "更新已有 skill"
    } elseif ($Force) {
        $resolvedTarget = [System.IO.Path]::GetFullPath($target).TrimEnd("\")
        $expectedTarget = [System.IO.Path]::GetFullPath((Join-Path $skillsDir "lufei-lessons")).TrimEnd("\")
        if ($resolvedTarget -ne $expectedTarget) {
            throw "强制安装目标路径校验失败：$resolvedTarget"
        }
        Remove-Item -LiteralPath $target -Recurse -Force
        git clone $RepoUrl $target
        Assert-GitSucceeded "重新克隆 skill"
    } else {
        throw "目标目录已存在但不是目标 Git 仓库：$target。需要清理后再安装，或使用 -Force。"
    }
} else {
    git clone $RepoUrl $target
    Assert-GitSucceeded "克隆 skill"
}

git -C $target config core.hooksPath .githooks
Assert-GitSucceeded "配置 Git 提交钩子"
git -C $target config user.name $GitUserName
Assert-GitSucceeded "配置 Git 提交者名称"
git -C $target config user.email $GitUserEmail
Assert-GitSucceeded "配置 Git 提交者邮箱"

$privateLog = Join-Path $target "references\lesson-log.md"
if (-not (Test-Path -LiteralPath $privateLog)) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $privateLog) | Out-Null
    "# 本机私有复盘记录`n" | Set-Content -LiteralPath $privateLog -Encoding utf8
}

Write-Output "lufei-lessons 安装完成：$target"
