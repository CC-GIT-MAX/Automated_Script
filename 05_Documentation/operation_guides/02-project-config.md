# 项目参数配置：project.env.bat

## 用途

`.scripts\project.env.bat` 保存当前项目的 IAR 路径、工程文件、Configuration、项目名称和日志目录。它由所有编译和报告脚本共同读取。

## 操作步骤

```powershell
notepad .\.scripts\project.env.bat
```

至少确认以下字段：

```bat
set "PROJECT_NAME=MyProject"
set "MCU_FAMILY=YTM32B1MD1"
set "IAR_BIN=D:\IAR_AND_JLINK\IAR_IDE\common\bin\iarbuild.exe"
set "IAR_PROJECT_SUBPATH=EWARM"
set "IAR_PROJECT_FILE=MyProject.ewp"
set "IAR_CONFIG=FLASH"
set "LOG_DIR=build_logs"
```

## 如何确认参数

- `IAR_BIN`：在 IAR 安装目录搜索 `iarbuild.exe`，通常位于 `common\bin`。
- `IAR_PROJECT_SUBPATH`：从项目根目录到 `.ewp` 所在目录的相对路径。
- `IAR_PROJECT_FILE`：`.ewp` 文件名，不包含目录。
- `IAR_CONFIG`：IAR 顶部 Configuration 下拉框中的名称，例如 `FLASH`，大小写保持一致。
- `MCU_FAMILY`：芯片型号，例如 `YTM32B1MD1`；供 Codex 理解上下文。

## 验证

```powershell
Test-Path $env:CD\.scripts\project.env.bat
.\.scripts\build.bat clean
```

如果脚本能打印正确的 IAR project、Config 和 Mode，说明配置已被读取。

## 安全要求

此文件含本机路径，默认在 `.gitignore` 中。执行 `git status` 时不应看到它。

## 常见问题

- `IAR project file not found`：检查 `IAR_PROJECT_SUBPATH` 与 `IAR_PROJECT_FILE` 拼接结果。
- `iarbuild.exe not found`：检查 `IAR_BIN`，不要填写 IAR IDE 主程序路径。
- `Not enough input arguments`：通常缺少 `IAR_CONFIG`。
- `Configuration ... not found`：打开 IAR 确认实际 Configuration 名称。
