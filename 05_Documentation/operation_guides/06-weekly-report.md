# 周报：weekly_report.bat / weekly_report.ps1

## 用途

采集日期范围内的日报，通过 Codex 去重、分类并生成周报。用户运行 `.bat`；同目录 `.ps1` 是内部实现。

## 前置条件

- 先创建至少一篇日报。
- 使用 Codex 模式时，`codex` 命令可用。

## 命令

```powershell
.\.scripts\weekly_report.bat
.\.scripts\weekly_report.bat --from 2026-07-13 --to 2026-07-19
.\.scripts\weekly_report.bat --no-codex
.\.scripts\weekly_report.bat --from 2026-07-13 --to 2026-07-19 --no-codex
```

| 参数 | 作用 |
|---|---|
| 无参数 | 当前周，周一到周日 |
| `--from YYYY-MM-DD` | 起始日期 |
| `--to YYYY-MM-DD` | 结束日期 |
| `--no-codex` | 不调用 Codex，生成手动汇总模板 |

## 推荐首次验证

```powershell
.\.scripts\weekly_report.bat --no-codex
```

确认日报数量和日期正确后，再去掉 `--no-codex`。

## 输出

`.scripts\reports\weekly\weekly_<FROM>_to_<TO>.md`。内容包括完成事项、进行中事项、风险、下周计划及日报原始来源。

## 成功标志

控制台显示找到的日报数量及输出路径，生成的 Markdown 包含目标日期范围。

## 常见问题

- `No daily reports directory`：先运行日报脚本。
- 找到 0 篇日报：检查文件日期和 `--from/--to`。
- Codex 失败：先用 `--no-codex` 保证模板可生成，再检查 Codex 登录和网络。
- 不要直接运行 `weekly_report.ps1`，除非调试内部参数绑定。

## 依赖文件清单与移植

`weekly_report.bat` 与伴生 PowerShell 脚本 `weekly_report.ps1` 必须放在同一目录。

### 复制位置与目标

| 仓库内源文件 | 目标项目中的部署路径 |
|---|---|
| `02_Template_Management\weekly_report_bat\weekly_report.bat` | `.scripts\weekly_report.bat` |
| `02_Template_Management\weekly_report_bat\weekly_report.ps1` | `.scripts\weekly_report.ps1` |
| `03_Helper_Libraries\common_bat\common.bat` | `.scripts\lib\common.bat` |
| `06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat` | `.scripts\project.env.bat` |
| 输入数据 | `.scripts\reports\daily\*.md`（由 `daily_report.bat` 产生） |

### 一次性移植命令

```bat
mkdir .scripts\lib 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\weekly_report_bat\weekly_report.bat" .scripts\weekly_report.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\weekly_report_bat\weekly_report.ps1" .scripts\weekly_report.ps1
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat" .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat" .scripts\project.env.bat
```

### 移植后验证

```bat
test -f .scripts\weekly_report.bat                REM 批处理入口存在
test -f .scripts\weekly_report.ps1                REM PowerShell 伴生脚本与 .bat 同目录
test -f .scripts\lib\common.bat                  REM 环境加载器存在
test -f .scripts\project.env.bat                 REM 配置存在
.scripts\daily_report 2026-07-15                 REM 先准备一篇日报
.scripts\weekly_report --no-codex --from 2026-07-15 --to 2026-07-15   REM 模板路径可用
.scripts\weekly_report --no-codex                REM 默认本周范围可用
dir .scripts\reports\weekly                      REM 输出文件存在
```

外部工具：PowerShell 5.1+、`codex` CLI（除非使用 `--no-codex`）。

