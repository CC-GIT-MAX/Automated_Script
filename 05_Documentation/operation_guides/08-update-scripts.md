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

## 依赖文件清单与移植

`update_scripts.bat` 与 `update.bat` 共同构成“共享仓库 → 项目内 .scripts\”同步链路。

### 复制位置与目标

| 仓库内源文件 | 部署位置 |
|---|---|
| `02_Template_Management\update_scripts_bat\update_scripts.bat` | 共享仓库目录 `<TEMPLATE_DIR>\update_scripts.bat` |
| `03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1` | 共享仓库目录 `<TEMPLATE_DIR>\..\..\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1`（脚本使用相对路径定位，不能平铺） |
| `02_Template_Management\update_bat\update.bat` | 项目内 `.scripts\update.bat` |

### 一次性移植整个共享仓库

```powershell
Copy-Item -Path "D:\working_file\WorkSpace\scripts\Automated_Script_Summary" `
          -Destination "D:\new-shared-template\" -Recurse -Force
```

只搬运 `update_scripts.bat` 时，必须保留以下相对路径：

```bat
mkdir D:\my-template\03_Helper_Libraries\compare_hash_ps1 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\update_scripts_bat\update_scripts.bat" D:\my-template\update_scripts.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1" D:\my-template\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1
```

然后把项目内 `.scripts\update.bat` 中的 `TEMPLATE_DIR` 改为 `D:\my-template`。

### 移植后验证

```bat
dir "<TEMPLATE_DIR>\update_scripts.bat"
dir "<TEMPLATE_DIR>\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1"
mkdir C:\sync-smoke\.scripts 2>nul
cd C:\sync-smoke
"<TEMPLATE_DIR>\update_scripts.bat"                REM dry-run
"<TEMPLATE_DIR>\update_scripts.bat" --apply        REM 应用
dir .scripts                                          REM build.bat / fix_build.bat 等已被同步
```

