# Codex 自动修复编译错误：fix_build.bat

## 用途

自动执行“编译 → 读取最新 IAR 日志 → Codex 修改源码 → 再编译”，直到成功或达到重试次数。

## 前置条件

```powershell
where.exe codex
.\.scripts\build.bat build
```

Codex 必须从项目根目录工作，并具有项目源码写权限。运行前确保重要改动已提交或可通过 Git 恢复。

## 命令

```powershell
.\.scripts\fix_build.bat       # 默认最多 5 轮
.\.scripts\fix_build.bat 1     # 推荐首次使用
.\.scripts\fix_build.bat 5
```

参数是最大重试次数。建议先用 `1` 检查 Codex 修改方向，再增加次数。

## 执行过程

1. 调用 `build.bat`。
2. 成功则立即退出。
3. 失败则定位最新 `build_logs\build_*.log`。
4. 调用 `codex exec -C <PROJECT_ROOT> -s workspace-write`。
5. Codex 每轮最多修改一个文件。
6. 再次编译确认修复是否有效。

## 每次运行后检查

```powershell
git status --short
git diff
.\.scripts\build.bat build
```

编译成功不等于板级功能正确；仍需 IAR 下载、烧录和硬件测试。

## 退出码

- `0`：编译成功。
- `1`：用尽重试次数。
- `2`：找不到 Codex CLI。
- `3`：配置或依赖缺失。

## 常见问题

- `outside the writable root`：从项目根目录启动 Codex，确保整个项目属于工作区。
- Codex 返回非零：检查网络、登录和额度；脚本仍会重试编译以确认局部修改是否生效。
- 修改了不希望修改的文件：立即检查 `git diff`，使用 `git restore <file>` 回滚单个文件。
- 连续多轮仍失败：停止自动循环，人工分析根因，不要无限提高重试次数。

## 依赖文件清单与移植

`fix_build.bat` 依赖 `build.bat` 的全部依赖，外加 Codex CLI。

### 复制位置与目标

| 仓库内源文件 | 目标项目中的部署路径 |
|---|---|
| `01_Build_Automation\fix_build_bat\fix_build.bat` | `.scripts\fix_build.bat` |
| `01_Build_Automation\build_bat\build.bat` | `.scripts\build.bat` |
| `03_Helper_Libraries\common_bat\common.bat` | `.scripts\lib\common.bat` |
| `06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat` | `.scripts\project.env.bat` |

### 一次性移植命令

```bat
where codex                                                 REM 必须能找到 codex CLI
mkdir .scripts\lib 2>nul
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\01_Build_Automation\fix_build_bat\fix_build.bat" .scripts\fix_build.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\01_Build_Automation\build_bat\build.bat" .scripts\build.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\03_Helper_Libraries\common_bat\common.bat" .scripts\lib\common.bat
copy /Y "D:\working_file\WorkSpace\scripts\Automated_Script_Summary\06_Project_Examples\YTM32B1MD1_FlexCAN\project.env.bat" .scripts\project.env.bat
```

### 移植后验证

```bat
where codex                                       REM Codex CLI 在 PATH 中
test -f .scripts\fix_build.bat                    REM 入口存在
test -f .scripts\build.bat                        REM 被调用方存在
test -f .scripts\lib\common.bat                   REM 环境加载器存在
.scripts\build.bat build                          REM 基线编译通过
.scripts\fix_build.bat 1                          REM 一轮 Codex 自动修复，结束后检查 git diff
```

外部工具：`codex` CLI（必需）、PowerShell（间接依赖）。

