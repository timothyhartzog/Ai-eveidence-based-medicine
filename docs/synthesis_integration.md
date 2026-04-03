# Grading → Synthesis Integration

## Purpose
Ensure synthesis uses structured evidence and grading outputs rather than raw text.

---

## Rules
1. Synthesis must ONLY consume:
   - structured extraction
   - grading schema
   - recommendation layer

2. Synthesis must NOT:
   - directly summarize raw abstracts
   - ignore grading outputs

---

## Required outputs
Synthesis must include:
- summary of evidence
- strength of evidence (certainty)
- recommendation strength
- explicit evidence gaps
- explicit conflicts
- population applicability statements

---

## Example structure
```json
{
  "summary": "Moderate-certainty neonatal evidence suggests benefit.",
  "certainty": "moderate",
  "recommendation": "conditional_for",
  "evidence_gaps": ["lack of term infant data"],
  "conflicts": ["inconsistent secondary outcomes"],
  "applicability": "direct_neonatal"
}
```

---

## Done when
- synthesis uses only structured inputs
- recommendation and certainty both appear
- extrapolation is explicitly stated when present
