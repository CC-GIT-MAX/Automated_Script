# 内部辅助脚本

这些文件由用户入口脚本自动调用，正常情况下不需要直接运行。

## common.bat

位置：项目中的 `.scripts\lib\common.bat`。

作用：定位项目根目录、加载 `.scripts\project.env.bat`、提供公共变量。`build.bat`、`fix_build.bat` 和报告包装器依赖它。

故障表现：配置文件缺失或变量为空。处理方式是先检查[项目参数配置](02-project-config.md)，不要把项目参数硬编码进 `common.bat`。

## compare_hash.ps1

位置：共享仓库 `03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1`。

作用：比较两个文件的 SHA256，向更新器输出 `SAME` 或差异结果。它由 `update_scripts.bat` 调用。

调试示例：

```powershell
& "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1" "file-a" "file-b"
```

## weekly_report.ps1 / monthly_report.ps1

位置：项目 `.scripts\`。它们负责日期计算、日报采集、Codex 调用和 Markdown 写入；对应 `.bat` 负责加载项目配置并翻译 `--from`、`--to`、`--month`、`--no-codex` 参数。

用户应运行：

```powershell
.\.scripts\weekly_report.bat
.\.scripts\monthly_report.bat
```

只有在调试 PowerShell 内部实现时才直接执行 `.ps1`，且必须提供 `-ProjectRoot` 等参数。

## 维护要求

修改任何 helper 前先阅读根 `AGENTS.md` 和 `_tracking\PITFALLS.md`，并重新验证所有调用它的用户入口脚本。

## 依赖文件清单与移植（helper 自身 + 使用它的入口脚本）

helper 不是独立运行的脚本，移植时必须连同其调用方一起复制。

### common.bat

| 仓库内源文件 | 部署路径 |
|---|---|
| `03_Helper_Libraries\common_bat\common.bat` | `.scripts\lib\common.bat` |
| `06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat` | `.scripts\project.env.bat` |
| `01_Build_Automation\build_bat\build.bat` | `.scripts\build.bat`（至少一个调用方） |

### compare_hash.ps1

| 仓库内源文件 | 部署路径 |
|---|---|
| `03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1` | `<TEMPLATE_DIR>\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1`（与 `update_scripts.bat` 的相对路径一致） |

### weekly_report.ps1 / monthly_report.ps1

| 仓库内源文件 | 部署路径 |
|---|---|
| `02_Template_Management\weekly_report_bat\weekly_report.ps1` | `.scripts\weekly_report.ps1`（与 `.bat` 同目录） |
| `02_Template_Management\monthly_report_bat\monthly_report.ps1` | `.scripts\monthly_report.ps1`（与 `.bat` 同目录） |

### 一次性移植命令

```bat
REM common.bat 与一个调用方（build.bat）的最小包
mkdir .scripts\lib 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat" .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\01_Build_Automation\build_bat\build.bat" .scripts\build.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat" .scripts\project.env.bat
```

```bat
REM compare_hash.ps1：必须放在与 update_scripts.bat 相对路径匹配的位置
mkdir "<TEMPLATE_DIR>\03_Helper_Libraries\compare_hash_ps1" 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1" "<TEMPLATE_DIR>\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1"
```

### 移植后验证

```bat
test -f .scripts\lib\common.bat                       REM common.bat 就位
test -f .scripts\build.bat                            REM 调用方存在
.scripts\build.bat build                              REM 调用方可加载 common.bat
dir "<TEMPLATE_DIR>\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1"
"<TEMPLATE_DIR>\update_scripts.bat"                   REM dry-run 成功
```

