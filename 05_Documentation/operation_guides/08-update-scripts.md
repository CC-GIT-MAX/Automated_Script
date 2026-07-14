# 更新与回滚：update_scripts.bat / update.bat

## 用途

比较共享仓库与项目 `.scripts\` 中的受管理文件，预览差异、创建备份并更新脚本，不覆盖 `project.env.bat`。

## 推荐：直接调用共享更新器

在目标项目根目录执行 dry-run：

```powershell
cmd /c "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\update_scripts_bat\update_scripts.bat"
```

状态含义：

- `[SAME]`：无需更新。
- `[DIFF]`：文件不同。
- `[NEW]`：项目中不存在。

确认后应用：

```powershell
cmd /c "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\update_scripts_bat\update_scripts.bat --apply"
```

不建议日常使用 `--no-backup`：

```powershell
cmd /c "...\update_scripts.bat --apply --no-backup"
```

## 项目本地 update.bat

`.scripts\update.bat` 是便捷包装器，但其中 `TEMPLATE_DIR` 必须改为当前机器的共享更新器目录。修改后可运行：

```powershell
.\.scripts\update.bat
.\.scripts\update.bat --apply
```

## 备份与回滚

应用更新前，旧文件保存在 `.scripts\backup\YYYYMMDD_HHMMSS\`。回滚示例：

```powershell
Copy-Item ".\.scripts\backup\20260714_003846\weekly_report.ps1" ".\.scripts\weekly_report.ps1" -Force
```

## 保留内容

更新器不会修改 `.scripts\project.env.bat`，也不会删除不在受管理列表中的自定义文件。

## 常见问题

- `Template incomplete`：共享仓库不完整或脚本位置改变。
- `.scripts not found`：先运行新项目初始化。
- 更新后行为异常：从最新备份恢复，并在共享仓库查看 `CHANGELOG.md`。
