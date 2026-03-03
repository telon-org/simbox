# Project Context (Auto-loaded)

This file is automatically loaded at session start to provide essential project context.

## Development Flows

This project uses structured development workflows. Each flow has documentation and templates.

### Available Flows

| Flow | Purpose | Documentation | Templates |
|------|---------|---------------|-----------|
| **SDD** | Spec-Driven Development | `flows/sdd.md` | `flows/.templates/sdd/` |
| **DDD** | Document-Driven Development | `flows/ddd.md` | `flows/.templates/ddd/` |
| **TDD** | Tests-Driven Development | `flows/tdd.md` | `flows/.templates/tdd/` |
| **VDD** | Visual-Driven Development | `flows/vdd.md` | `flows/.templates/vdd/` |
| **ADR** | Architecture Decision Records | `flows/adr.md` | `flows/.templates/adr/` |

### Orchestration Commands

| Command | Approach | Purpose |
|---------|----------|---------|
| `/waterfall` | BFS | Complete ALL docs before ANY implementation |
| `/roadmap` | DFS | Shortest path to specific goal or MVP |
| `/legacy` | Reverse | Analyze existing code, generate docs |

**BFS vs DFS:**
```
/waterfall (BFS):              /roadmap (DFS):
  All REQ approved               flow-1: REQ→SPEC→PLAN→IMPL ✓
  All SPEC approved              flow-2: REQ→SPEC→PLAN→IMPL ✓
  All PLAN approved              Goal achieved!
  Master plan                    (other flows skipped)
  Implementation
```

### Quick Reference

- **Start flow**: `/sdd start [name]`, `/ddd start [name]`, etc.
- **Resume flow**: `/sdd resume [name]`, `/ddd resume [name]`, etc.
- **Start ADR**: `/adr start [name]`
- **List ADRs**: `/adr list`
- **Full project (BFS)**: `/waterfall`
- **Target goal (DFS)**: `/roadmap "user can login"`
- **MVP (DFS)**: `/roadmap`

---

## ADR Index Summary

> **Note**: This section provides a quick overview of all Architecture Decision Records.
> For full details, read the specific ADR file linked below.

<!-- ADR_INDEX_START -->
### Active ADRs

| # | Title | Status | File |
|---|-------|--------|------|
| - | No ADRs created yet | - | - |

### Statistics

- **Total ADRs**: 0
- **Approved**: 0
- **In Review**: 0
- **Draft**: 0
- **Rejected**: 0

### ADR Index File

Full index with metadata, tags, and relationships: `flows/adr-index.md`
<!-- ADR_INDEX_END -->

---

## Active Flows Summary

> **Note**: This section lists active development flows (features in progress).
> Content of each flow is NOT loaded automatically - read specific files as needed.

<!-- FLOWS_INDEX_START -->
### SDD Flows (Spec-Driven)

| Name | Status File | Current Phase |
|------|-------------|---------------|
| - | No active SDD flows | - |

### DDD Flows (Document-Driven)

| Name | Status File | Current Phase |
|------|-------------|---------------|
| - | No active DDD flows | - |

### TDD Flows (Tests-Driven)

| Name | Status File | Current Phase |
|------|-------------|---------------|
| - | No active TDD flows | - |

### VDD Flows (Visual-Driven)

| Name | Status File | Current Phase |
|------|-------------|---------------|
| - | No active VDD flows | - |
<!-- FLOWS_INDEX_END -->

---

## Quick Navigation

### Core Documentation

- Project README: `README.md`
- Flow documentation: `flows/*.md`
- Templates: `flows/.templates/`

### Commands

- Claude Code: `.claude/commands/`
- Cursor: `.cursor/prompts/commands/`
- Qwen: `.qwen/commands/`
- Gemini: `.gemini/commands/`

### When to Read More

- **Starting new feature**: Read flow documentation (`flows/[flow].md`)
- **Resuming work**: Read `_status.md` in the feature directory
- **Making architectural decision**: Read `flows/adr.md`, check existing ADRs
- **Understanding past decisions**: Check ADR index and specific ADR files

---

## Conventions

### Flow Directory Naming

```
flows/sdd-[feature-name]/    # SDD flows
flows/ddd-[feature-name]/    # DDD flows
flows/tdd-[feature-name]/    # TDD flows
flows/vdd-[feature-name]/    # VDD flows
flows/adr-[NNN]-[name]/      # ADRs (numbered)
flows/waterfall/             # BFS orchestration state
flows/roadmap/               # DFS orchestration state
flows/legacy/                # Reverse engineering state
```

### Status Tracking

Each flow maintains `_status.md` with:
- Current phase
- Progress checklist
- Blockers
- Context notes for resuming

### Phase Transitions

All phase transitions require explicit user approval:
- "requirements approved"
- "specs approved"
- "plan approved"
- "ready for review" (ADR)
- "ADR approved" / "ADR rejected"

---

*This file is auto-loaded. Update ADR Index and Flows Summary sections when ADRs or flows change.*
