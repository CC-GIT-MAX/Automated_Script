# 保存后自动编译：auto_build_watcher.ps1

## 用途

监控源码目录中的 `.c`、`.h`、`.cpp`、`.s` 保存事件，延迟去抖后自动运行 `build.bat`；失败时询问是否启动自动修复。

## 前置条件

- `.scripts\build.bat` 已能独立编译。
- 项目中至少存在一个默认监控目录：`app`、`board`、`platform`、`middleware`、`rtos`。
- PowerShell 5.0 或以上。

## 启动

在项目根目录打开单独的 PowerShell 窗口：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\.scripts\auto_build_watcher.ps1
```

保持窗口运行，按 `Ctrl+C` 停止。

## 行为

1. 找到存在的监控目录。
2. 递归监听源文件变化。
3. 保存后等待约 3 秒，避免编辑器重复事件。
4. 执行 `.scripts\build.bat build`。
5. 失败时询问是否运行 `.scripts\fix_build.bat 5`。

## 成功标志

启动后显示 `Auto-build watcher started` 和实际监控目录；保存源文件后出现编译输出。

## 常见问题

- 保存后没有反应：源码不在默认监控目录，需修改脚本中的 `$watchedDirs`。
- 一次保存触发多次：编辑器产生多种文件事件；等待去抖完成，避免快速连续保存。
- 网络盘事件不稳定：建议在本地磁盘使用。
- 首次启用前不要跳过手动 `build.bat build` 验证。

## 依赖文件清单与移植

`auto_build_watcher.ps1` 自身只是一个文件，但它运行时调用整个自动化栈。

### 复制位置与目标

| 仓库内源文件 | 目标项目中的部署路径 |
|---|---|
| `04_File_Watcher\auto_build_watcher_ps1\auto_build_watcher.ps1` | `.scripts\auto_build_watcher.ps1` |
| `01_Build_Automation\build_bat\build.bat` | `.scripts\build.bat`（被监视器调用） |
| `01_Build_Automation\fix_build_bat\fix_build.bat` | `.scripts\fix_build.bat`（失败时可选调用） |
| `03_Helper_Libraries\common_bat\common.bat` | `.scripts\lib\common.bat`（被 build/fix_build 调用） |
| `06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat` | `.scripts\project.env.bat` |

### 一次性移植命令

```bat
mkdir .scripts\lib 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\04_File_Watcher\auto_build_watcher_ps1\auto_build_watcher.ps1" .scripts\auto_build_watcher.ps1
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\01_Build_Automation\build_bat\build.bat" .scripts\build.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\01_Build_Automation\fix_build_bat\fix_build.bat" .scripts\fix_build.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat" .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat" .scripts\project.env.bat
```

推荐使用 `new_project.bat` 一次性安装全部脚本，再启动监视器。

### 移植后验证

```powershell
Test-Path .\.scripts\auto_build_watcher.ps1            # 监视器存在
cmd /c ".\.scripts\build.bat build"                    # 退出 0
Test-Path .\app; Test-Path .\board; Test-Path .\platform   # 至少有一个默认监视目录
$PSVersionTable.PSVersion                              # Major >= 5
powershell -NoProfile -ExecutionPolicy Bypass -File .\.scripts\auto_build_watcher.ps1   # 启动，Ctrl+C 停止
```

外部工具：PowerShell 5.0+、`codex` CLI（仅在修复提示时使用）、IAR 工具链（经由 `build.bat` 间接调用）。

