# AGENTS.md -- Operation Guides

## Purpose

This directory contains user-facing Chinese operating procedures for every
script in the automation suite.

## Rules

- Commands, paths, flags, environment variables, and console output stay in English.
- Each user-facing script guide must include purpose, prerequisites, syntax,
  steps, parameters, outputs, success criteria, common failures, and rollback.
- Companion `.ps1` files and shared helpers are documented as internal
  dependencies; users should normally run the `.bat` entry point.
- Verify commands against the current script before updating a guide.
- When script behavior changes, update its guide and `_tracking/CHANGELOG.md`
  in the same commit.
