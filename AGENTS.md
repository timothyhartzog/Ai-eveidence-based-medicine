# AGENTS.md

Follow structured, deterministic development.

## Core rules
- JSON-only outputs for all LLM agents
- Deterministic pipeline (no autonomous flow decisions)
- PubMed is source of truth
- No synthesis without structured extraction

## Development style
- Small modules
- Strong typing
- Explicit schemas
- Validate everything

## Tasks
Always:
1. Inspect repo
2. Work in small increments
3. Add tests
4. Verify before moving on
