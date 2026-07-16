# 日报：daily_report.bat

## 用途

创建指定日期的工作记录，为周报和月报提供结构化数据源。

## 命令

```powershell
.\.scripts\daily_report.bat
.\.scripts\daily_report.bat 2026-07-14
.\.scripts\daily_report.bat --regen
.\.scripts\daily_report.bat --append "Fixed CAN wake-up timing issue"
```

| 参数 | 作用 |
|---|---|
| 无参数 | 创建今天的日报 |
| `YYYY-MM-DD` | 创建指定日期日报 |
| `--regen` | 覆盖今天已有日报 |
| `--append "text"` | 向今天日报追加一条内容 |

## 输出

日报保存在 `.scripts\reports\daily\YYYY-MM-DD.md`。新建后脚本会尝试用系统默认编辑器打开文件。

## 推荐填写内容

- 完成事项及对应项目。
- 编译、烧录、板级测试结果。
- Code Review 和合并请求。
- 阻塞、风险、待协调事项。
- 明日计划。

## 成功标志

出现 `[OK] Created` 或 `[OK] Appended`，对应 Markdown 文件存在。

## 常见问题

- `[SKIP] ... already exists`：使用 `--append` 补充，或确认后使用 `--regen` 重建。
- 报告目录无法创建：检查 `.scripts` 写权限。
- 周报缺少内容：确保日报日期落在周报范围内，文件名必须是 `YYYY-MM-DD.md`。

## 依赖文件清单与移植

`daily_report.bat` 是纯批处理脚本，没有 `.ps1` 伴生文件。

### 复制位置与目标

| 仓库内源文件 | 目标项目中的部署路径 |
|---|---|
| `02_Template_Management\daily_report_bat\daily_report.bat` | `.scripts\daily_report.bat` |
| `03_Helper_Libraries\common_bat\common.bat` | `.scripts\lib\common.bat` |
| `06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat` | `.scripts\project.env.bat` |

### 一次性移植命令

```bat
mkdir .scripts\lib 2>nul
mkdir .scripts\reports\daily 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\daily_report_bat\daily_report.bat" .scripts\daily_report.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat" .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat" .scripts\project.env.bat
```

### 移植后验证

```bat
test -f .scripts\daily_report.bat                REM 主入口存在
test -f .scripts\lib\common.bat                  REM 环境加载器存在
test -f .scripts\project.env.bat                 REM 配置存在
.scripts\daily_report                            REM 创建今日日报
.scripts\daily_report 2026-07-15                 REM 指定日期可写
.scripts\daily_report --regen                    REM 覆盖标志生效
.scripts\daily_report --append "smoke-test entry" REM 追加标志生效
dir .scripts\reports\daily                       REM 输出文件存在
```

外部工具：PowerShell（用于日期正则校验）。

