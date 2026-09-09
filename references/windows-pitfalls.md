# Windows 专项踩坑

## 中文乱码和编码

- 修改、生成、读取中文文件前先确认编码。
- 中文源码、配置、Markdown、JSON、YAML、日志优先使用 UTF-8。
- 如果项目原文件是 UTF-8 BOM、GBK、GB2312 或其他编码，不要盲目转换。
- PowerShell 输出中文乱码时，检查 `$OutputEncoding`、控制台 code page、文件编码、Python/Node 读取编码。
- Python 读写中文文件显式使用 `encoding="utf-8"`，除非确认项目使用其他编码。
- Node.js 读写中文文件显式使用 `utf8`。
- bat/cmd 中文乱码时，检查 UTF-8 BOM、ANSI/GBK、`chcp 65001` 和调用程序编码，不要只改一处。
- Docker 容器内中文乱码时，检查 locale、字体、环境变量、应用编码、日志编码和数据库编码。
- 生成图片、PDF、Canvas、水印、OCR、截图时，中文乱码常见根因是字体缺失，不只是编码问题。
- 修复乱码后，全局搜索并验证所有类似中文显示点。

## 中文路径和空格路径

- Windows 路径可能包含中文、空格、括号、特殊字符，命令必须正确加引号。
- 不要把 Windows 路径直接当 Linux 路径用；区分 `C:\xxx`、`F:\xxx`、UNC 路径、WSL `/mnt/c/xxx`。
- PowerShell 路径优先使用 `-LiteralPath`，避免 `[]`、通配符、中文路径被误解析。
- 脚本不要假设项目路径没有空格或中文。
- 文件拖拽、批量导入、图片识别、重命名功能必须测试中文文件名、中文文件夹、空格路径。

## PowerShell、CMD、bat、ps1

- Windows 默认 shell 通常是 PowerShell，不要照搬 Linux bash 命令。
- 不要混用 PowerShell、cmd、bash 的语法。
- PowerShell 删除、移动、复制文件时优先用原生命令，并使用 `-LiteralPath`。
- 不要递归删除不确定路径。
- bat 启动失败时，检查工作目录、相对路径、环境变量、权限、编码、依赖是否在 PATH。
- ps1 无法运行时，考虑 ExecutionPolicy；不要随便全局放宽安全策略，优先用当前进程级别并说明影响。
- PowerShell 里超长 here-string / 大文本写文件可能触发 206 或引号解析问题；长内容优先落临时文件、`Set-Content -Encoding utf8` 或 Python 读写，不要把整段正文硬塞进一条命令。

## 环境变量和 PATH

- Windows 上工具已安装但命令不可用，常见原因是 PATH 没配置或当前终端没刷新。
- 检查 Dart、Flutter、Java、Android SDK、Node、Python、Git、Docker、gh、adb 等工具时，同时检查安装位置和 PATH。
- 修改 PATH 后，说明是否需要重启终端、VS Code、Docker Desktop 或系统。
- 不要把 secret 写进环境变量示例或日志。

## Git 和换行符

- 注意 CRLF/LF 变化，避免造成大量无关 diff。
- 不要格式化无关文件。
- 提交前检查 `git diff --stat` 和实际 diff，确认没有编码、换行符、格式化造成的大面积改动。
- 中文文件名或 Git 输出乱码时，检查 Git 编码配置，例如 `core.quotepath`。

## Docker Desktop / WSL

- Windows Docker 部署要区分 Docker Desktop、WSL2、Linux 容器、Windows 路径挂载。
- compose 路径挂载要确认 Windows 路径是否正确映射到容器。
- 容器内中文字体、时区、locale、文件权限、换行符都可能导致 Windows 本地正常但 Docker 异常。
- 本地已有服务时，优先更新已有容器，不要随便新建端口。
- Docker 构建失败时，检查 `.dockerignore`、上下文目录、镜像体积、依赖缓存、网络、平台架构和中文字体包。

## 权限、锁定和后台进程

- Windows 文件可能被程序占用，删除/覆盖失败时先查占用进程。
- 修改 exe、dll、数据库、日志、图片输出目录前，检查应用是否正在运行。
- 需要管理员权限时先说明原因；不要默认要求管理员权限。
- 端口占用时，查清楚进程是谁，不要随便杀进程。

## UI、截图和字体

- Windows 桌面软件 UI 要测试高 DPI、缩放比例、中文字体、按钮文字是否被截断。
- 中文按钮、tab、表格列、弹窗标题要检查不同分辨率下是否溢出。
- 生成图片、水印、PDF、Excel、Word 时，要检查中文字体是否真实渲染，而不是方块、问号或乱码。
- 截图验证时要看真实界面，不要只看构建成功。

## 文件操作和批量处理

- 批量重命名、移动、复制、备份前，必须先确认目标目录和文件匹配范围。
- 备份文件要按功能分类，不要全部堆到一个目录。
- 批量图片/OCR/重命名任务要测试：只有原图、只有水印图、原图+水印图、中文名、空文件夹、重复文件名、拖入文件夹。
- 自动清理生成文件时，要确认清理范围，不要误删用户原始文件。

## pwsh / PowerShell 7

- 项目或 AGENTS.md 明确要求 `pwsh` 时，先检查 `pwsh` 是否可用：`pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion'`。如果缺失，优先修复 PowerShell 7 环境。
- 只有项目脚本确认兼容时，才用 `powershell.exe` 替代 `pwsh`；不要把 Windows PowerShell 5 作为长期替代。

## MSIX / App Installer 自签名证书

- MSIX 自签名包在开发机能安装，不代表新电脑能双击安装；开发机往往已信任签名证书。
- 新电脑提示 `0x800B0109`、证书不受信任时，先确认随包 `.cer` 是否已导入当前用户 `TrustedPeople`，必要时也导入 `Root`，再安装 `.msixbundle`。
- 交付自签名 MSIX 时不要只给 `.msixbundle`；必须同时给 `.cer`、一键导证书+安装脚本、安装说明，或优先交付不需要证书的绿色版。
- 验证安装包时同时检查 `Get-AuthenticodeSignature`、新电脑/干净用户证书状态、zip 内是否包含证书和脚本，不只在开发机双击验证。
