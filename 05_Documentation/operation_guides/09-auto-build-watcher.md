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
