# AGENTS.md -- 05_Documentation (overview)

This folder contains all the **documentation** that ships with the template.

| Subfolder | What it is | When to update |
|---|---|---|
| `AGENTS_md/` | The per-project `AGENTS.md` template (with `[FILL ...]` placeholders) | When adding a new collaboration rule |
| `README_md/` | The main user-facing README | When workflow changes |
| `codex_prompt_library/` | All Codex prompts we use (compile-fix, code review, etc.) | When adding a new prompt |
| `fill_in_checklist/` | The P0/P1/P2/P3 checklist for filling in `project.env.bat` and `AGENTS.md` | When new required fields are added |

## How documentation is versioned

Documentation files are versioned **with the scripts**, not separately. If you
change a script''s behavior, update the corresponding docs in the same commit.
The CHANGELOG.md should mention the doc update.

## How documentation is consumed

- `AGENTS.md` (per-project) is loaded by Codex CLI/Desktop when working in a
  project. It defines the rules Codex must follow.
- `README.md` is the entry point for new users. It is **not** loaded by Codex.
- `codex_prompt_library.md` is a copy-paste reference. The prompts are also
  embedded in scripts that use them.
- `AGENTS_FILL_IN_CHECKLIST.md` is a one-time aid when setting up a new
  project.