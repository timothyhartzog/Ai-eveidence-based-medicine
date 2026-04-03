# Pediatric Evidence Grading Schema

## Purpose
This schema grades evidence for neonatal and pediatric reviews with explicit handling of:
- direct pediatric evidence
- neonatal-specific evidence
- extrapolated adult evidence
- study design strength
- outcome relevance
- certainty of evidence

The schema is intended for use by the appraisal agent and persistence layer.

---

## Core principles
1. Direct neonatal evidence ranks above broader pediatric evidence when the review target is neonatal.
2. Direct pediatric evidence ranks above adult extrapolation when the review target is pediatric.
3. Study design strength matters, but directness to the target population can override a stronger but less applicable study.
4. Certainty must be separated from recommendation strength.
5. All grading decisions must include rationale.

---

## Output shape
```json
{
  "population_directness": {
    "target_scope": "neonatal",
    "evidence_scope": "neonatal",
    "directness_level": "direct",
    "score": 4,
    "rationale": "Study exclusively enrolled preterm neonates in the NICU."
  },
  "study_design": {
    "label": "randomized_controlled_trial",
    "score": 4,
    "rationale": "Parallel-group randomized trial with defined comparator."
  },
  "outcome_relevance": {
    "label": "critical",
    "score": 4,
    "rationale": "Primary outcomes include mortality and severe IVH."
  },
  "risk_of_bias": {
    "label": "moderate",
    "score": 2,
    "rationale": "Allocation concealment unclear; outcome assessment otherwise acceptable."
  },
  "consistency": {
    "label": "moderate",
    "score": 2,
    "rationale": "Findings align with most comparable studies but not all."
  },
  "precision": {
    "label": "moderate",
    "score": 2,
    "rationale": "Confidence intervals are moderately wide."
  },
  "extrapolation_flag": false,
  "overall_certainty": {
    "label": "moderate",
    "score": 3,
    "rationale": "Direct population match and strong design, limited by moderate bias and precision."
  },
  "summary": "Moderate-certainty direct neonatal evidence",
  "grader_confidence": 0.89
}
```

---

## Dimension definitions

### 1. Population directness
Measures how closely the study population matches the review target.

#### Allowed values
- `direct_neonatal` = 4
- `direct_pediatric` = 4
- `mixed_pediatric_with_neonatal_subgroup` = 3
- `pediatric_but_not_neonatal_for_neonatal_question` = 2
- `adult_extrapolated_to_pediatric` = 1
- `unusable_for_target_population` = 0

#### Interpretation
- Neonatal review: neonatal-only evidence is preferred.
- Pediatric review: pediatric-only evidence is preferred.
- Adult extrapolation must be explicitly flagged.

---

### 2. Study design strength
Use this hierarchy unless strong limitations justify downgrading.

#### Suggested values
- `systematic_review_or_meta_analysis_of_relevant_trials` = 5
- `randomized_controlled_trial` = 4
- `prospective_cohort` = 3
- `retrospective_cohort` = 2
- `case_control` = 2
- `case_series_or_case_report` = 1
- `expert_opinion_or_narrative_review` = 0

Note: Guidelines should be graded on the evidence they cite, not treated as primary high-strength evidence by default.

---

### 3. Outcome relevance
Measures how clinically important the reported outcomes are for the target review.

#### Suggested values
- `critical` = 4
- `important` = 3
- `intermediate_surrogate` = 2
- `limited_relevance` = 1
- `not_relevant` = 0

Examples:
- Critical: mortality, severe IVH, NEC, neurodevelopmental impairment
- Important: length of stay, need for transfusion, treatment escalation
- Intermediate surrogate: lab marker change without direct clinical outcome

---

### 4. Risk of bias
Higher score means lower bias concern.

#### Suggested values
- `low` = 3
- `moderate` = 2
- `high` = 1
- `critical` = 0

---

### 5. Consistency
Rates how well findings align with comparable evidence.

#### Suggested values
- `high` = 3
- `moderate` = 2
- `low` = 1
- `unknown` = 0

---

### 6. Precision
Rates certainty around estimates.

#### Suggested values
- `high` = 3
- `moderate` = 2
- `low` = 1
- `very_low` = 0

---

## Overall certainty mapping
Recommended certainty labels:
- `high`
- `moderate`
- `low`
- `very_low`

### Suggested scoring rule
Compute a provisional total:
- population_directness: 0-4
- study_design: 0-5
- outcome_relevance: 0-4
- risk_of_bias: 0-3
- consistency: 0-3
- precision: 0-3

Maximum = 22

Suggested mapping:
- 18-22 = `high`
- 13-17 = `moderate`
- 8-12 = `low`
- 0-7 = `very_low`

### Required downgrades
Force cap at `low` if:
- evidence is adult-only for a neonatal question
- evidence is adult-only for a pediatric question and no direct pediatric evidence exists
- risk_of_bias is `critical`

Force cap at `moderate` if:
- only surrogate outcomes are reported
- strong indirectness remains unresolved

---

## Extrapolation rules
Set `extrapolation_flag = true` when:
- adult studies are used for pediatric review conclusions
- broader pediatric studies are used for neonatal conclusions
- subgroup applicability is uncertain

When extrapolation is flagged, rationale must state:
1. source population
2. target population
3. why extrapolation is being used
4. what the main limitation is

---

## Database fields
Recommended persistence fields in `appraisals` or related grading table:
- `population_directness_label`
- `population_directness_score`
- `study_design_label`
- `study_design_score`
- `outcome_relevance_label`
- `outcome_relevance_score`
- `risk_of_bias_label`
- `risk_of_bias_score`
- `consistency_label`
- `consistency_score`
- `precision_label`
- `precision_score`
- `extrapolation_flag`
- `overall_certainty_label`
- `overall_certainty_score`
- `grading_rationale_json`
- `grader_confidence`

---

## Agent requirements
The appraisal agent must:
- emit strict JSON only
- fill every grading dimension
- provide rationale for every dimension
- explicitly state when evidence is extrapolated
- avoid claiming `high` certainty if the evidence is indirect or high risk of bias

---

## Test cases
At minimum, test:
1. direct neonatal RCT with critical outcomes
2. pediatric cohort study for pediatric question
3. adult RCT being extrapolated to pediatrics
4. neonatal subgroup extracted from mixed pediatric cohort
5. case series with surrogate outcomes only

---

## Definition of done
Implementation is complete when:
- schema is represented in typed Julia models
- appraisal agent outputs validate against the schema
- database can persist grading fields
- synthesis layer can distinguish direct pediatric evidence from extrapolated evidence
- tests cover direct, indirect, and extrapolated scenarios
