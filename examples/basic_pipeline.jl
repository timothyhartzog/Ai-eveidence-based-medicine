using SQLite
using GradingEngine
using GradingRepo

# Initialize DB
 db = SQLite.DB("example.sqlite")
create_grading_tables!(db)

# Example grading
g = compute_certainty(
    target_scope="neonatal",
    evidence_scope="neonatal",
    population_directness=DIRECT_NEONATAL,
    study_design=RANDOMIZED_CONTROLLED_TRIAL,
    outcome_relevance=CRITICAL,
    risk_of_bias=MODERATE_BIAS,
    consistency=MODERATE_CONSISTENCY,
    precision=MODERATE_PRECISION,
    extrapolation_flag=false,
    rationale_population="Direct neonatal study",
    rationale_study_design="RCT",
    rationale_outcome="Critical outcomes",
    rationale_bias="Moderate bias",
    rationale_consistency="Consistent",
    rationale_precision="Moderate precision"
)

# Example recommendation
r = compute_recommendation(
    g;
    benefit_harm=PROBABLY_FAVORS_BENEFIT,
    feasibility=MODERATE_FEASIBILITY,
    preference_sensitivity=MODERATE_PREFERENCE_SENSITIVITY,
    applicability_label="direct_neonatal",
    applicability_score=2,
    rationale_benefit_harm="Benefit > harm",
    rationale_feasibility="Feasible",
    rationale_preference="Moderate variation",
    rationale_applicability="Direct"
)

upsert_grading_and_recommendation!(db, "review1", "PMID123", g, r)

println("Pipeline complete")
