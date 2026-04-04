# AI Evidence-Based Medicine

This repository contains the build prompts, planning files, and repo instructions for a Julia-based AI evidence-review system focused on neonatal and pediatric literature.

## Included
- `AGENTS.md` — repo operating rules for Codex
- `PLANS.md` — phased implementation plan
- `CODEX_PROMPTS/` — iterative prompts to build the system in controlled steps

## Recommended first Codex prompt

```text
Read AGENTS.md and PLANS.md.
Inspect the repository.
Complete Phase 0, then implement Phase 1 only.
Return:
- files changed
- commands to run
- verification steps
- any blockers
```

## Target system
- Julia
- Genie.jl
- PubMed E-utilities
- Ollama
- Apple Silicon / MLX-aware model routing
- SQLite first, PostgreSQL-ready later

## Implemented evidence layers

A minimal Julia module now exists under `src/` implementing:
- pediatric/neonatal grading enums and typed output structs
- recommendation-layer enums and typed output structs
- validation and downgrade caps
- SQL persistence fields in `db/schema.sql`

Run tests with:

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

## Review pipeline quickstart

```bash
julia --project -e 'using Pkg; Pkg.instantiate()'
julia --project examples/basic_pipeline.jl
```

Required services:
- PubMed E-utilities (network)
- Local Ollama server at `http://localhost:11434` (override with `OllamaClient(base_url=...)`)
