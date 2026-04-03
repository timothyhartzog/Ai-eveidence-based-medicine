module PediatricEvidence

export TargetScope,
    EvidenceScope,
    PopulationMatch,
    StudyDesign,
    OutcomeRelevance,
    RiskOfBias,
    ConsistencyLevel,
    PrecisionLevel,
    CertaintyLevel,
    RecommendationStrength,
    BenefitHarmBalance,
    FeasibilityLevel,
    PreferenceSensitivity,
    population_directness_score,
    population_applicability_score,
    study_design_score,
    outcome_relevance_score,
    risk_of_bias_score,
    consistency_score,
    precision_score,
    certainty_score,
    recommendation_strength_score,
    benefit_harm_score,
    feasibility_score,
    preference_sensitivity_score,
    NEONATAL_CRITICAL_OUTCOMES,
    PEDIATRIC_CRITICAL_OUTCOMES,
    GradingOutput,
    RecommendationOutput,
    build_grading_output,
    build_recommendation_output,
    validation_errors

include("types.jl")
include("constants.jl")
include("grading.jl")
include("recommendation.jl")

end
