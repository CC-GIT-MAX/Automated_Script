# 新项目初始化：new_project.bat

## 用途

把共享仓库中的编译、自动修复、日报、周报、月报、更新和文件监控脚本部署到新项目的 `.scripts\`。

## 前置条件

- Windows PowerShell 或 cmd。
- 已克隆脚本仓库：`D:\working_file\WorkSpace\scripts\Automated_Script_Summary`。
- 当前目录必须是目标项目根目录。

## 操作步骤

```powershell
cd "D:\working_file\MyProject"
& "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\new_project_bat\new_project.bat"
```

PowerShell 可以直接用 `&`。如果通过 cmd 执行：

```bat
cd /d D:\working_file\MyProject
"D:\working_file\WorkSpace\scripts\Automated_Script_Summary\02_Template_Management\new_project_bat\new_project.bat"
```

如果 `.scripts\` 已存在，输入 `Y` 会更新受管理脚本；输入 `N` 取消。已有的 `.scripts\project.env.bat` 和项目根目录 `AGENTS.md` 会保留。

## 生成文件

- `.scripts\build.bat`
- `.scripts\fix_build.bat`
- `.scripts\daily_report.bat`
- `.scripts\weekly_report.bat`、`.scripts\weekly_report.ps1`
- `.scripts\monthly_report.bat`、`.scripts\monthly_report.ps1`
- `.scripts\auto_build_watcher.ps1`
- `.scripts\update.bat`
- `.scripts\lib\common.bat`
- `.scripts\project.env.bat`
- 项目根目录 `AGENTS.md`

同时向 `.gitignore` 加入配置、日志、报告和备份目录。

## 成功标志

控制台显示 `[DONE] Bootstrap completed.`，并且 `.scripts\build.bat` 与 `.scripts\project.env.bat` 存在。

## 下一步

先完成[项目参数配置](02-project-config.md)，再运行编译测试。

## 常见问题

- `[ERROR] Required template file missing`：共享仓库文件不完整，先执行 `git status`、`git pull` 检查仓库。
- 在错误目录执行：脚本会把当前目录当成项目根目录；删除误生成的 `.scripts\` 后进入正确目录重试。
- 二次安装不会恢复旧脚本版本；如需回滚，使用 Git 或 `.scripts\backup\`。

## 依赖文件清单与移植

`new_project.bat` 是发行引导器，本身需要读取整个仓库。无法只复制一个文件就完成移植。

### 复制位置与目标

| 仓库内源文件 | 目标项目中的部署路径 |
|---|---|
| `01_Build_Automation\build_bat\build.bat` | `.scripts\build.bat` |
| `01_Build_Automation\fix_build_bat\fix_build.bat` | `.scripts\fix_build.bat` |
| `03_Helper_Libraries\common_bat\common.bat` | `.scripts\lib\common.bat` |
| `02_Template_Management\daily_report_bat\daily_report.bat` | `.scripts\daily_report.bat` |
| `02_Template_Management\weekly_report_bat\weekly_report.bat` | `.scripts\weekly_report.bat` |
| `02_Template_Management\weekly_report_bat\weekly_report.ps1` | `.scripts\weekly_report.ps1` |
| `02_Template_Management\monthly_report_bat\monthly_report.bat` | `.scripts\monthly_report.bat` |
| `02_Template_Management\monthly_report_bat\monthly_report.ps1` | `.scripts\monthly_report.ps1` |
| `04_File_Watcher\auto_build_watcher_ps1\auto_build_watcher.ps1` | `.scripts\auto_build_watcher.ps1` |
| `02_Template_Management\update_bat\update.bat` | `.scripts\update.bat` |
| `06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat` | `.scripts\project.env.bat`（若不存在则拷贝） |
| `05_Documentation\AGENTS_md\AGENTS.md` | 项目根目录 `AGENTS.md`（若不存在则拷贝） |

### 一次性移植到新的共享仓库位置

```powershell
Copy-Item -Path "D:\working_file\WorkSpace\scripts\Automated_Script_Summary" `
          -Destination "D:\new-shared-template\" -Recurse -Force
```

然后修改新位置的 `update.bat` 中的 `TEMPLATE_DIR` 即可让现有项目重新指向新位置。

### 移植后验证

```powershell
test-path "D:\new-shared-template\02_Template_Management\new_project_bat\new_project.bat"   REM 入口存在
test-path "D:\new-shared-template\03_Helper_Libraries\compare_hash_ps1\compare_hash.ps1"    REM 比较脚本存在
test-path "D:\new-shared-template\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat"   REM 环境样例存在
```

