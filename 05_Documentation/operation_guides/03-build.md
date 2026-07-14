# IAR 自动编译：build.bat

## 用途

调用 `iarbuild.exe` 编译 IAR 工程，并把完整输出保存到 `build_logs\`。

## 前置条件

- 已完成 `project.env.bat` 配置。
- IAR Command Line Build Utility 可以运行。
- 在项目根目录执行。

## 命令

```powershell
.\.scripts\build.bat
.\.scripts\build.bat build
.\.scripts\build.bat clean
.\.scripts\build.bat rebuild
.\.scripts\build.bat make
```

| 模式 | 作用 |
|---|---|
| 无参数 / `build` | 标准编译 |
| `clean` | 清理中间文件 |
| `rebuild` | 清理后完整编译 |
| `make` | 增量构建 |

## 执行过程

1. `common.bat` 读取项目配置。
2. 拼接 `.ewp` 完整路径。
3. 生成时间戳日志名。
4. 执行 `iarbuild <project> -<mode> <config>`。
5. 返回 IAR 的退出码。

## 输出与成功标志

日志示例：`build_logs\build_20260714_091500.log`。退出码 `0` 表示成功；非零表示失败。出现失败时先打开最新日志：

```powershell
Get-ChildItem .\build_logs\*.log | Sort-Object LastWriteTime -Descending | Select-Object -First 1
```

## 常见问题

- IAR 命令能单独运行但脚本失败：检查带空格路径是否完整写在变量中。
- 日志为空：检查日志目录写权限。
- Configuration 错误：回到[项目参数配置](02-project-config.md)。
- 编译错误需要自动处理：继续阅读[Codex 自动修复](04-fix-build.md)。
