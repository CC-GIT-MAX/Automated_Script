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
