# 月报：monthly_report.bat / monthly_report.ps1

## 用途

采集指定月份的日报，并可参考周报，通过 Codex 生成月度总结、统计、风险和下月计划。用户运行 `.bat`，`.ps1` 是内部实现。

## 命令

```powershell
.\.scripts\monthly_report.bat
.\.scripts\monthly_report.bat --month 2026-07
.\.scripts\monthly_report.bat --no-codex
.\.scripts\monthly_report.bat --month 2026-07 --no-codex
```

| 参数 | 作用 |
|---|---|
| 无参数 | 当前月份 |
| `--month YYYY-MM` | 指定月份 |
| `--no-codex` | 只生成手动汇总模板 |

## 推荐首次验证

```powershell
.\.scripts\monthly_report.bat --month 2026-07 --no-codex
```

先确认日报采集范围，再使用 Codex 模式。

## 输出

`.scripts\reports\monthly\monthly_YYYY-MM.md`。内容通常包括月度成果、项目进展、问题与风险、统计、下月计划，以及日报/周报来源。

## 成功标志

输出文件存在，月份正确，报告中显示采集到的日报数量。

## 常见问题

- 月份格式必须是 `YYYY-MM`。
- 日报数量为 0：检查 `.scripts\reports\daily` 中的日期。
- Codex 汇总内容不准确：先修正日报原始信息，再重新生成；源数据质量决定汇总质量。
- 不要直接修改 `monthly_report.ps1` 的生成提示，除非同时更新脚本规范和本指南。

## 依赖文件清单与移植

`monthly_report.bat` 与伴生 PowerShell 脚本 `monthly_report.ps1` 必须放在同一目录。

### 复制位置与目标

| 仓库内源文件 | 目标项目中的部署路径 |
|---|---|
| `02_Template_Management\monthly_report_bat\monthly_report.bat` | `.scripts\monthly_report.bat` |
| `02_Template_Management\monthly_report_bat\monthly_report.ps1` | `.scripts\monthly_report.ps1` |
| `03_Helper_Libraries\common_bat\common.bat` | `.scripts\lib\common.bat` |
| `06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat` | `.scripts\project.env.bat` |
| 输入数据 | `.scripts\reports\daily\*.md` 与 `.scripts\reports\weekly\*.md` |

### 一次性移植命令

```bat
mkdir .scripts\lib 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\monthly_report_bat\monthly_report.bat" .scripts\monthly_report.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\monthly_report_bat\monthly_report.ps1" .scripts\monthly_report.ps1
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat" .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat" .scripts\project.env.bat
```

### 移植后验证

```bat
test -f .scripts\monthly_report.bat               REM 批处理入口存在
test -f .scripts\monthly_report.ps1               REM PowerShell 伴生脚本与 .bat 同目录
test -f .scripts\lib\common.bat                  REM 环境加载器存在
test -f .scripts\project.env.bat                 REM 配置存在
.scripts\monthly_report --no-codex 2026-07       REM 月份参数可用
.scripts\monthly_report --no-codex --from 2026-07-01 --to 2026-07-31   REM 显式区间可用
.scripts\monthly_report --no-codex               REM 默认当月可用
dir .scripts\reports\monthly                     REM 输出文件存在
```

外部工具：PowerShell 5.1+、`codex` CLI（除非使用 `--no-codex`）。

