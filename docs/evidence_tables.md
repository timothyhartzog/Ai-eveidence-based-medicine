# Evidence Tables Specification

## Purpose
Create structured, exportable evidence tables for neonatal and pediatric systematic reviews.

---

## Table schema
Each row represents one study.

Fields:
- citation_id
- study_design
- population_description
- gestational_age_range
- sample_size
- intervention
- comparator
- outcomes
- key_results
- harms
- limitations
- population_directness
- overall_certainty
- recommendation_strength

---

## Requirements
- derived ONLY from structured extraction + grading
- no raw text synthesis allowed
- must support CSV + JSON export
- must support filtering:
  - neonatal vs pediatric
  - study design
  - certainty level

---

## Output formats
1. CSV (for publication)
2. JSON (for pipeline use)
3. Markdown (for reports)

---

## Done when
- tables generate from stored data
- exports work
- filters work
