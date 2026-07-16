# 自动化脚本操作手册

本目录是 `Automated_Script_Summary` 的用户操作入口。脚本中心负责保存标准版本；每个实际项目通过 `.scripts\` 使用它们。

## 推荐阅读顺序

1. [新项目初始化](01-new-project.md)
2. [项目参数配置](02-project-config.md)
3. [IAR 自动编译](03-build.md)
4. [Codex 自动修复编译错误](04-fix-build.md)
5. [日报](05-daily-report.md)
6. [周报](06-weekly-report.md)
7. [月报](07-monthly-report.md)
8. [更新与回滚](08-update-scripts.md)
9. [保存代码后自动编译](09-auto-build-watcher.md)
10. [内部辅助脚本](10-helper-scripts.md)

## 脚本运行位置

除初始化脚本外，命令都应在目标项目根目录执行。项目根目录是包含 `.scripts`、源码目录和 IAR 工程目录的位置。

```powershell
cd "D:\working_file\MyProject"
```

## 日常流程

```powershell
# 开始开发或检查当前状态
.\.scripts\build.bat build

# 编译失败后，先允许 Codex 尝试一轮
.\.scripts\fix_build.bat 1

# 记录当天工作
.\.scripts\daily_report.bat --append "Completed CAN wake-up validation"

# 周五生成周报
.\.scripts\weekly_report.bat

# 月底生成月报
.\.scripts\monthly_report.bat --month 2026-07
```

## 安全原则

- 自动修复后必须运行 `git diff` 检查源码变化。
- `.scripts\project.env.bat` 含本机绝对路径，不提交到 Git。
- 更新脚本前先 dry-run，正式更新默认保留备份。
- 首次使用报告脚本时先加 `--no-codex` 验证数据采集。
- 遇到脚本异常先阅读 `_tracking/PITFALLS.md`。

## 依赖文件清单与移植约定

每份指南最后都包含 “依赖文件清单与移植” 小节，列出该脚本需要的仓库内源文件、项目本地文件、外部工具，以及可直接复制使用的移植命令与验证步骤。需要单独搬运某个脚本到另一台机器或项目时，按对应指南的这段说明操作即可，无需克隆整个仓库。

## 一次性搬运整个自动化栈到新机器

```powershell
Copy-Item -Path "D:\working_file\WorkSpace\scripts\Automated_Script_Summary" `
          -Destination "<NEW_TEMPLATE_DIR>\" -Recurse -Force
```

然后在新机器上执行 `new_project.bat`，把整栈部署到目标项目。
