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
