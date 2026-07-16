# AGENTS.md 填空清单

> 这份清单按"先做哪一步、改哪一行"排序，配套文件是 `outputs/AGENTS.md`。
> 当前文件状态：MCU 平台 `YTM32B1MD14`、烧录工具 `J-Link` 已填好；其余关键字段仍需补充。

---

## 用法

1. 按顺序打开 `outputs/AGENTS.md`，按"行号 / 区块 → 填什么 → 怎么查"逐项替换
2. 全部填完后删除本文件
3. 提交到 git，组员拉取后 Codex 自动加载新规范

---

## P0 — 必须填，否则 Codex 帮不了你

### A. 编译器版本与构建命令（影响 `fix_build.sh` 是否能跑通）

| 行号 / 区块 | 当前内容 | 改成什么 | 怎么查 |
|---|---|---|---|
| 第 13 行 "编译器" | `IAR Embedded Workbench for ARM XX.X` | 实际版本号，例如 `IAR Embedded Workbench for ARM 9.40.1` | IAR 菜单 Help → About |
| 第 14 行 "构建工具" | `IAR 命令行 `iarbuild`` | 实际封装命令，建议改成 `scripts/build.sh`（绝对路径或相对仓库根的说明） | 你们的 `scripts/build.sh` 文件 |
| 第 16 行 "烧录工具" | `J-Link` | 如果是 IAR 自带 I-Jet / OpenOCD / JLink，改成实际工具名 + 型号 | 项目实际烧录工具 |
| 第 45-50 行 "必须定义的宏" | 仍是 `USE_HAL_DRIVER` / `STM32F407xx` | 改成 YTM32 实际宏，例如 `YTM32B1MD14` / `__YTM32__` / FPU 相关宏 | IAR 工程 Options → C/C++ Compiler → Defined Symbols |
| 第 53-56 行 "包含路径" | 仍按 STM32 习惯写 | 改成 YTM32 实际路径：厂商 SDK 路径、YTM32 标准库路径、FreeRTOS 实际路径 | IAR 工程 Options → C/C++ Compiler → Include Paths |

**为什么先做这个**：这些字段决定 Codex 能不能正确解析 `#include`、能不能调用对的工具链。先把它填对，Codex 修编译错误才有意义。

---

### B. 项目元信息

| 区块 | 当前内容 | 改成什么 | 怎么查 |
|---|---|---|---|
| 第 1 节 "项目类型" | `嵌入式 C/C++ 量产项目` | 补充具体产品线 / 项目代号，例如 `车载 BCM 控制器，量产第 3 代` | 项目立项书 |
| 第 12 行 "MCU 平台" | `YTM32B1MD14` | 已填，**保留** | — |
| 第 15 行 "代码标准" | `C99（部分模块 C++11）` | 改成你们实际遵守的 MISRA-C 等级或公司内标，例如 `MISRA-C 2012 + C99` | 公司编码规范文档 |

---

## P1 — 强烈建议填，影响 Codex 协作流程准确性

### C. 调试日志分析模板（第 5.3 节）

把里面的 `STM32F407 @ 168MHz` 全部替换：

| 当前占位 | 替换为 |
|---|---|
| `【MCU】STM32F407 @ 168MHz` | `【MCU】YTM32B1MD14 @ [实际主频]MHz` |
| `【项目】xxx 项目` | `【项目】[你的产品线名 / 内部代号]` |
| `【相关代码路径】BSP/uart/uart.c` | 留占位或改成最常用的模块路径，例如 `BSP/can/can.c` |

> 这些是示例代码块，Codex 不会真的执行，但占位文字太泛会让组员照抄时漏掉关键信息。

---

### D. 编译错误处理流程（第 5.2 节）

检查示例 prompt 是否还符合你们实际工作流：

- 第 110 行 `[运行 scripts/build.sh 2>&1 | tee build.err]` → 确认你们 `scripts/` 目录下确实叫 `build.sh`
- 第 112 行 `[对 Codex 说：]` 后面的 prompt → 看是否要加上"使用 `--approval-mode on-failure`"这类具体参数
- 第 116 行 `[开发者本地二次编译验证]` → 如果你们用 Jenkins / GitLab CI 自动验证，这一步可以改成"等待 CI 通过"

---

### E. 目录结构（第 2 节）

如果你们仓库布局不是 `APP/BSP/DRV/MIDDLEWARE/INC/PROJECT/scripts/docs`，按实际目录改写：

- 把示例 tree 替换成 `tree -L 2 -I 'node_modules'` 的真实输出
- 第 36-38 行 "模块归属规则" 里的路径 `BSP/` / `DRV/` 同步改

---

## P2 — 锦上添花，提升 Codex 建议质量

### F. 常用 warning 处理原则（第 4 节）

当前表里都是 STM32 常见 warning。YTM32 工具链如果 warning 编号不同：

- 把 `Pe177` / `Pe167` / `Pe546` / `Pe144` / `Pa082` 替换成你们 IAR 实际报告的 warning 编号
- 表格里"处理方式"列要写你们组内统一约定，不能照搬

**怎么查**：故意写一行有问题的代码，看 IAR 报的 warning 编号。

---

### G. 硬件安全红线（第 6 节）

默认清单（启动文件 / 中断向量表 / PLL / 看门狗 / Flash 写 / 电源管理 / Bootloader）已经覆盖了常见风险。

你们项目如果有额外敏感项，**追加**：
- [ ] OTA 升级签名验证
- [ ] 安全密钥 / 证书处理
- [ ] CAN 诊断 UDS 服务
- [ ] 标定 / Calibration 数据
- [ ] 客户专属协议

---

## P3 — 长期维护

### H. 文档元信息（文件末尾）

| 当前内容 | 改成什么 |
|---|---|
| `**维护者**：(填写组内负责人)` | 写真实姓名 + 工号 / 邮箱 |
| `**最后更新**：(填写日期)` | 改成本次更新日期，格式 `YYYY-MM-DD` |

---

## 验收清单

填完后，对照下面 5 条逐项确认：

- [ ] 打开新终端，跑 `codex "读取 AGENTS.md 第 1 节，告诉我项目用的是什么 MCU 和编译器"`，回答与现实一致
- [ ] 跑 `codex "按 AGENTS.md 第 4 节的宏定义检查当前代码是否有未声明符号"`，能给出有意义的回复
- [ ] 组里另一位同事拉取最新 `AGENTS.md` 后，Codex 提的建议风格与你预期一致
- [ ] 用一个真实的编译错误跑通 `fix_build.sh`，Codex 能定位到具体行
- [ ] 故意触发一个硬件相关文件（启动文件 / PLL）的改动请求，Codex 按红线拒绝直接修改

5 项都打勾，说明 `AGENTS.md` 已经可以作为团队基线发布。

---

## 排错参考

如果填完后 Codex 行为异常：

| 现象 | 原因 | 修复 |
|---|---|---|
| Codex 不读 AGENTS.md | 文件不在仓库根目录 | 移到仓库根 |
| Codex 读的是旧版本 | 缓存未刷新 | 重启 Codex 会话 |
| Codex 建议与规范冲突 | 提示词里临时指定了其他规则 | 在 prompt 末尾加"以 AGENTS.md 为准" |
| warning 编号对不上 | IAR 版本不同 | 重新故意制造一次 warning，对照修改 |

---

**配套文件**：
- `outputs/AGENTS.md` — 待填空的主文件
- `outputs/codex_prompt_library.md` — 提示词速查手册
