# AGENTS.md -- Embedded Project Codex Collaboration Rules

> This file is auto-loaded by Codex CLI / Codex Desktop when working in this repo.
> All team members must follow these rules.

---

## 1. Project Background

- **Project type**: [FILL: e.g. Automotive BCM controller, production gen 3]
- **MCU platform**: [FILL: e.g. STM32F407 / NXP RT1064 / YTM32B1MD1]
- **Compiler**: IAR Embedded Workbench for ARM
- **Build tool**: `.scripts/build.bat` (wraps iarbuild, logs to build_logs/)
- **Coding standard**: [FILL: e.g. C99 / MISRA-C 2012]
- **Flasher**: [FILL: J-Link / I-Jet / OpenOCD]
- **IAR Build Configuration**: [FILL: e.g. FLASH / Debug / Release]

## 2. Directory Structure

```
project_root/
|-- APP/ or app/            # Application layer
|-- BSP/ or board/          # Board support package
|-- DRV/ or platform/       # Drivers
|-- MIDDLEWARE/             # Third-party / vendor middleware
|-- INC/ or include/        # Public headers
|-- EWARM/ or iar/          # IAR project files (*.ewp, *.eww)
|-- .scripts/               # Build, flash, test scripts
|-- build_logs/             # Build logs (gitignored)
`-- docs/                   # Design docs
```

**Module ownership rules:**
- Modifying BSP/board code --> MUST run .scripts/build.bat + hardware smoke test
- Modifying startup file / vector table / linker script --> MUST be reviewed by senior engineer

## 3. Code Style

### Naming

| Type       | Rule                         | Example                |
|------------|------------------------------|------------------------|
| Function   | lowerCamelCase, module prefix| `flexcan_init()`       |
| Variable   | lowerCamelCase               | `rx_buffer_len`        |
| Macro      | UPPER_SNAKE_CASE             | `MAX_RX_SIZE`          |
| Typedef    | `module_name_t`              | `flexcan_handle_t`     |
| File name  | lower_snake_case             | `flexcan_driver.c`     |

### Format

- 4-space indent, no tabs
- Line width <= 100 chars
- Allman braces (left brace on its own line)
- Doxygen comments in headers

## 4. Compiler Constraints

### Required defined symbols (Defined Symbols)

[FILL: copy from IAR Project --> Options --> C/C++ Compiler --> Preprocessor]
```
[FILL: e.g. STM32F407xx / USE_HAL_DRIVER / __FPU_PRESENT=1]
```

### Include paths

[FILL: copy from IAR Project --> Options --> C/C++ Compiler --> Preprocessor --> Additional include directories]
```
[FILL: e.g. $PROJ_DIR$\..\Inc]
```

### Common warning handling

| Warning  | Action                                |
|----------|---------------------------------------|
| `Pe177`  | Fix unused variable, do NOT pragma-out|
| `Pe167`  | Add declaration or include            |
| `Pe546`  | Verify if struct really needs packed  |
| `Pe144`  | Use explicit type for pointer compare |

**Forbidden**: `#pragma warning(disable:xxx)` blanket suppression.

## 5. Codex Collaboration Rules

### 5.1 Before asking Codex to change code, define:

1. Target feature or bug fix
2. Affected modules and files
3. Acceptance criteria (compile pass? unit test? hardware test?)
4. Whether hardware-related code is involved (yes --> human review required)

### 5.2 Compile error handling flow

```
[Local IAR build fails]
       |
       v
[Run .scripts\build.bat build  -->  build_logs\build_*.log]
       |
       v
[Tell Codex:]
"Run .scripts/build.bat, fix errors in build_logs/latest.log until build passes.
 Show git diff when done. Do not touch startup_*.s and *.icf."
       |
       v
[Or use the auto-loop:]
.\.scripts\fix_build.bat 5
       |
       v
[Developer runs .scripts\build.bat build locally to double-check]
```

**Forbidden:**
- Asking Codex to directly modify startup files / vector table / linker scripts
- Asking Codex to change more than 5 files in one session
- Letting Codex auto-commit
- Bypassing .scripts/build.bat to call iarbuild directly (loses logs)

### 5.3 Debug log analysis flow

When sharing logs with Codex, **MUST** include:

```
[Project]: [FILL project name]
[MCU]: [FILL e.g. STM32F407 @ 168MHz]
[Log type]: UART / J-Link RTT / Logic analyzer
[Expected behavior]: xxx
[Actual behavior]: xxx
[Tried so far]: xxx
[Related code]: path/to/file.c
```

### 5.4 Code review collaboration

Before opening a PR, run Codex pre-review:

```
Review current git diff per AGENTS.md rules. Focus on:
1. Naming convention compliance
2. Unused variables / functions
3. Error handling completeness (return checks, NULL checks)
4. Thread safety (FreeRTOS multi-task)
5. Hardware magic numbers (clock division, delay params)
Output: file-grouped [Critical/Warning/Suggestion] list
```

**Developer responsibility**: After Codex pre-review passes, MUST manually review hardware-related code.

## 6. Hardware Safety Red Lines

Codex can only SUGGEST, not directly modify:

- [ ] Startup file `startup_*.s` / `startup_*.c`
- [ ] Interrupt vector table
- [ ] Clock initialization (PLL)
- [ ] Watchdog-related code
- [ ] Flash write operations (bootloader)
- [ ] Power management / low-power transitions
- [ ] Bootloader main flow

## 7. Prohibited Actions

- Codex MUST NOT directly push to main branch
- CI MUST NOT auto-merge Codex-generated PRs
- Production keys, flashing passwords, customer IP MUST NOT be in code or logs
- Codex MUST NOT do large-scale refactors without an isolated branch
- Customer data in debugger/emulator logs MUST NOT be sent out

## 8. Common Codex Prompts

See `docs/codex_prompt_library.md` (recommended to copy from template).

---

**Maintainer**: [FILL name + email]
**Last updated**: [FILL date YYYY-MM-DD]
