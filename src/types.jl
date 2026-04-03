@enum TargetScope begin
    neonatal_target
    pediatric_target
end

@enum EvidenceScope begin
    neonatal_evidence
    pediatric_evidence
    mixed_pediatric_with_neonatal_subgroup_evidence
    adult_evidence
    unusable_evidence
end

"""
Shared population matching enum used by both grading directness and recommendation applicability.
"""
@enum PopulationMatch begin
    direct_neonatal
    direct_pediatric
    mixed_or_partial_match
    pediatric_non_neonatal_for_neonatal_question
    extrapolated
    unusable_for_target_population
end

@enum StudyDesign begin
    systematic_review_or_meta_analysis_of_relevant_trials
    randomized_controlled_trial
    prospective_cohort
    retrospective_cohort
    case_control
    case_series_or_case_report
    expert_opinion_or_narrative_review
end

@enum OutcomeRelevance begin
    critical
    important
    intermediate_surrogate
    limited_relevance
    not_relevant
end

@enum RiskOfBias begin
    low_bias
    moderate_bias
    high_bias
    critical_bias
end

@enum ConsistencyLevel begin
    high_consistency
    moderate_consistency
    low_consistency
    unknown_consistency
end

@enum PrecisionLevel begin
    high_precision
    moderate_precision
    low_precision
    very_low_precision
end

@enum CertaintyLevel begin
    high_certainty
    moderate_certainty
    low_certainty
    very_low_certainty
end

@enum RecommendationStrength begin
    strong_for
    conditional_for
    conditional_against
    strong_against
    insufficient_for_recommendation
end

@enum BenefitHarmBalance begin
    clearly_favors_benefit
    probably_favors_benefit
    uncertain_or_balanced
    probably_favors_harm
    clearly_favors_harm
end

@enum FeasibilityLevel begin
    high_feasibility
    moderate_feasibility
    low_feasibility
    not_feasible
end

@enum PreferenceSensitivity begin
    low_preference_sensitivity
    moderate_preference_sensitivity
    high_preference_sensitivity
end

struct GradingOutput
    target_scope::TargetScope
    evidence_scope::EvidenceScope
    population_directness::PopulationMatch
    population_directness_score::Int
    study_design::StudyDesign
    study_design_score::Int
    outcome_relevance::OutcomeRelevance
    outcome_relevance_score::Int
    risk_of_bias::RiskOfBias
    risk_of_bias_score::Int
    consistency::ConsistencyLevel
    consistency_score::Int
    precision::PrecisionLevel
    precision_score::Int
    extrapolation_flag::Bool
    surrogate_only_outcomes::Bool
    overall_certainty::CertaintyLevel
    overall_certainty_score::Int
    summary::String
    rationale::Dict{String,String}
    downgrade_reasons::Vector{String}
    grader_confidence::Float64
end

struct RecommendationOutput
    recommendation_strength::RecommendationStrength
    recommendation_strength_score::Int
    benefit_harm_balance::BenefitHarmBalance
    benefit_harm_balance_score::Int
    feasibility::FeasibilityLevel
    feasibility_score::Int
    preference_sensitivity::PreferenceSensitivity
    preference_sensitivity_score::Int
    population_applicability::PopulationMatch
    population_applicability_score::Int
    recommendation_summary::String
    cautions::Vector{String}
    rationale::Dict{String,String}
    grader_confidence::Float64
end
