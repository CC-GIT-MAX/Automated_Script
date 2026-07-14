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
