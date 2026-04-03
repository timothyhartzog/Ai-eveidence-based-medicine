# Grade Recommendation Layer

## Purpose
This layer converts certainty of evidence into a recommendation framework while keeping recommendation strength separate from certainty alone.

It is designed for neonatal and pediatric evidence reviews where:
- evidence may be direct or extrapolated
- harms and benefits may differ by age group
- feasibility and implementation context matter

---

## Core principle
A strong recommendation does not follow automatically from high-certainty evidence, and low-certainty evidence does not always prohibit a provisional or conditional recommendation.

Recommendation strength must be based on:
1. certainty of evidence
2. balance of benefit and harm
3. directness to target population
4. feasibility / implementation burden
5. value sensitivity or preference sensitivity

---

## Recommendation output schema
```json
{
  "recommendation_strength": {
    "label": "conditional_for",
    "score": 2,
    "rationale": "Moderate-certainty neonatal evidence suggests benefit, but implementation burden and uncertainty in subgroup effects remain."
  },
  "benefit_harm_balance": {
    "label": "probably_favors_benefit",
    "score": 2,
    "rationale": "Reduction in clinically important outcomes outweighs modest increase in monitoring burden."
  },
  "feasibility": {
    "label": "moderate",
    "score": 2,
    "rationale": "Intervention is available in most NICU settings, but training and workflow adaptation may be needed."
  },
  "preference_sensitivity": {
    "label": "moderate",
    "score": 1,
    "rationale": "Caregiver and clinician preferences may vary where outcomes are uncertain or burdens are nontrivial."
  },
  "population_applicability": {
    "label": "direct_neonatal",
    "score": 2,
    "rationale": "Recommendation is based on evidence directly relevant to preterm neonates."
  },
  "recommendation_summary": "Conditional recommendation in favor for the neonatal target population.",
  "cautions": [
    "Do not generalize to term infants without direct evidence.",
    "Monitor for implementation-related harms or workflow failures."
  ],
  "grader_confidence": 0.84
}
```

---

## Strength labels
Recommended labels:
- `strong_for` = 3
- `conditional_for` = 2
- `conditional_against` = 1
- `strong_against` = 0
- `insufficient_for_recommendation` = -1

Interpretation:
- `strong_for`: benefits clearly outweigh harms, evidence is reasonably direct, and implementation is broadly supportable.
- `conditional_for`: benefit probably outweighs harm, but uncertainty or implementation concerns remain.
- `conditional_against`: harms, burden, or weak benefit signal make routine use questionable.
- `strong_against`: harms or lack of benefit clearly argue against use.
- `insufficient_for_recommendation`: evidence too indirect, sparse, or inconsistent for a useful recommendation.

---

## Benefit-harm balance
Labels:
- `clearly_favors_benefit` = 3
- `probably_favors_benefit` = 2
- `uncertain_or_balanced` = 1
- `probably_favors_harm` = 0
- `clearly_favors_harm` = -1

This must be derived from clinically meaningful outcomes, not from surrogate markers alone.

---

## Feasibility
Labels:
- `high` = 3
- `moderate` = 2
- `low` = 1
- `not_feasible` = 0

Factors:
- equipment needs
- training burden
- workflow complexity
- cost and access
- NICU or pediatric setting constraints

---

## Preference sensitivity
Labels:
- `low` = 2
- `moderate` = 1
- `high` = 0

High preference sensitivity should generally reduce recommendation strength unless benefit is overwhelming.

---

## Population applicability
Labels:
- `direct_neonatal` = 2
- `direct_pediatric` = 2
- `mixed_or_partial_match` = 1
- `extrapolated` = 0

If applicability is `extrapolated`, recommendation strength should usually be capped at `conditional_for` or `conditional_against`, and may need to default to `insufficient_for_recommendation`.

---

## Decision rules
Suggested rules:
1. If overall certainty is `very_low`, default to `insufficient_for_recommendation` unless there is a compelling harm signal.
2. If evidence is extrapolated and benefits are uncertain, cap at `conditional_for`.
3. If benefit-harm balance clearly favors harm, recommendation should be `conditional_against` or `strong_against`.
4. If benefit-harm balance clearly favors benefit, certainty is moderate or high, and applicability is direct, allow `strong_for` when feasibility is not low.
5. If only surrogate outcomes are available, cap at `conditional_for` unless additional direct clinical outcomes support stronger action.

---

## Database fields
Suggested persistence fields:
- `recommendation_strength_label`
- `recommendation_strength_score`
- `benefit_harm_balance_label`
- `benefit_harm_balance_score`
- `feasibility_label`
- `feasibility_score`
- `preference_sensitivity_label`
- `preference_sensitivity_score`
- `population_applicability_label`
- `population_applicability_score`
- `recommendation_summary`
- `recommendation_cautions_json`
- `recommendation_rationale_json`
- `recommendation_confidence`

---

## Agent requirements
The recommendation layer must:
- consume grading outputs from the appraisal layer
- use structured evidence summaries, not uncontrolled prose
- emit strict JSON only
- explicitly state when recommendation strength is limited by indirectness or uncertainty
- preserve cautions and non-generalization warnings

---

## Definition of done
Complete when:
- recommendation schema exists in typed models
- appraisal plus recommendation outputs can be stored
- synthesis can render recommendation strength separately from certainty
- tests cover neonatal direct evidence, pediatric direct evidence, and adult extrapolated evidence
