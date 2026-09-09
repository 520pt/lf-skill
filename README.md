# 路飞个人工作规则 Skill

这是王路飞的个人 Codex skill，用于统一跨项目的沟通方式、需求确认、编码边界、验证要求、临时文件处理和长期工程原则。

## 内容边界

公开仓库只保存可以跨电脑、跨项目复用的内容：

- `SKILL.md`：skill 入口和使用规则；
- `references/personal-rules.md`：沟通、编码、修改和输出要求；
- `references/engineering-patterns.md`：跨项目工程规律；
- `references/windows-pitfalls.md`：Windows 通用问题；
- `scripts/`：新增复盘和安装、同步辅助脚本。

本机的 `references/lesson-log.md` 是私有复盘记录，可能包含本地路径、项目名称、接口和其他隐私信息，因此默认不上传 GitHub。

规则中的授权继承仅适用于同一操作链，不会自动扩大到新的账号、网站、数据、权限或高风险动作。

## 一键安装

在 Windows PowerShell 中执行：

```powershell
irm https://raw.githubusercontent.com/520pt/lf-skill/main/scripts/install.ps1 | iex
```

安装脚本会把 skill 安装到：

```text
%USERPROFILE%\.codex\skills\lufei-lessons
```

如果系统没有 Git，脚本会提示先安装。已有同一仓库时，脚本会执行快进更新；如果目标目录不是 Git 仓库，不会强行覆盖。脚本还会在该仓库的本地 Git 配置中写入默认提交者 `520pt <520pt@users.noreply.github.com>`，不会修改全局 Git 配置。

如果需要改提交者，可以在安装时传入参数：

```powershell
& "$HOME\.codex\skills\lufei-lessons\scripts\install.ps1" -GitUserName "你的名称" -GitUserEmail "你的邮箱"
```

## 手动安装

```powershell
git clone https://github.com/520pt/lf-skill.git "$HOME\.codex\skills\lufei-lessons"
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$HOME\.codex\skills\lufei-lessons\scripts\setup-git-hooks.ps1"
```

## 更新和自动推送

在本机修改公开文件后执行：

```powershell
pwsh -NoLogo -NoProfile -ExecutionPolicy Bypass -File "$HOME\.codex\skills\lufei-lessons\scripts\sync-to-github.ps1" -Message "Update lufei-lessons"
```

首次配置完成后，Git 提交钩子会在本仓库创建提交后自动执行 `git push`。如果推送失败，脚本会保留本地提交并输出失败原因。

## 安全说明

- 不要把密码、令牌、Cookie、私钥、`.env`、本地账号状态或项目私有配置上传到公开仓库。
- 修改规则后先检查 `git diff` 和未跟踪文件，再提交推送。
- `lesson-log.md` 默认被 `.gitignore` 排除；如果确实要公开某条经验，应先改写为不含隐私的通用版本。
