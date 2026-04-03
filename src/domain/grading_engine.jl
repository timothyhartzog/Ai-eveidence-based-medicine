module GradingEngine

using JSON3

export
    PopulationDirectness,
    StudyDesign,
    OutcomeRelevance,
    RiskOfBias,
    ConsistencyLevel,
    PrecisionLevel,
    CertaintyLevel,
    BenefitHarmBalance,
    FeasibilityLevel,
    PreferenceSensitivity,
    RecommendationStrength,
    ScoredDimension,
    PopulationDirectnessAssessment,
    GradingResult,
    RecommendationResult,
    EvidenceTableRow,
    compute_certainty,
    compute_recommendation,
    validate_grading_result,
    validate_recommendation_result,
    neonatal_critical_outcomes,
    pediatric_critical_outcomes,
    normalize_outcome_label

@enum PopulationDirectness begin
    DIRECT_NEONATAL = 4
    DIRECT_PEDIATRIC = 4
    MIXED_PEDIATRIC_WITH_NEONATAL_SUBGROUP = 3
    PEDIATRIC_NOT_NEONATAL_FOR_NEONATAL_QUESTION = 2
    ADULT_EXTRAPOLATED_TO_PEDIATRIC = 1
    UNUSABLE_FOR_TARGET_POPULATION = 0
end

@enum StudyDesign begin
    EXPERT_OPINION_OR_NARRATIVE_REVIEW = 0
    CASE_SERIES_OR_CASE_REPORT = 1
    RETROSPECTIVE_COHORT = 2
    CASE_CONTROL = 2
    PROSPECTIVE_COHORT = 3
    RANDOMIZED_CONTROLLED_TRIAL = 4
    SYSTEMATIC_REVIEW_OR_META_ANALYSIS_OF_RELEVANT_TRIALS = 5
end

@enum OutcomeRelevance begin
    NOT_RELEVANT = 0
    LIMITED_RELEVANCE = 1
    INTERMEDIATE_SURROGATE = 2
    IMPORTANT = 3
    CRITICAL = 4
end

@enum RiskOfBias begin
    CRITICAL_BIAS = 0
    HIGH_BIAS = 1
    MODERATE_BIAS = 2
    LOW_BIAS = 3
end

@enum ConsistencyLevel begin
    UNKNOWN_CONSISTENCY = 0
    LOW_CONSISTENCY = 1
    MODERATE_CONSISTENCY = 2
    HIGH_CONSISTENCY = 3
end

@enum PrecisionLevel begin
    VERY_LOW_PRECISION = 0
    LOW_PRECISION = 1
    MODERATE_PRECISION = 2
    HIGH_PRECISION = 3
end

@enum CertaintyLevel begin
    VERY_LOW_CERTAINTY = 0
    LOW_CERTAINTY = 1
    MODERATE_CERTAINTY = 2
    HIGH_CERTAINTY = 3
end

@enum BenefitHarmBalance begin
    CLEARLY_FAVORS_HARM = -1
    PROBABLY_FAVORS_HARM = 0
    UNCERTAIN_OR_BALANCED = 1
    PROBABLY_FAVORS_BENEFIT = 2
    CLEARLY_FAVORS_BENEFIT = 3
end

@enum FeasibilityLevel begin
    NOT_FEASIBLE = 0
    LOW_FEASIBILITY = 1
    MODERATE_FEASIBILITY = 2
    HIGH_FEASIBILITY = 3
end

@enum PreferenceSensitivity begin
    HIGH_PREFERENCE_SENSITIVITY = 0
    MODERATE_PREFERENCE_SENSITIVITY = 1
    LOW_PREFERENCE_SENSITIVITY = 2
end

@enum RecommendationStrength begin
    INSUFFICIENT_FOR_RECOMMENDATION = -1
    STRONG_AGAINST = 0
    CONDITIONAL_AGAINST = 1
    CONDITIONAL_FOR = 2
    STRONG_FOR = 3
end

enum_label(x::PopulationDirectness) = begin
    if x == DIRECT_NEONATAL
        "direct_neonatal"
    elseif x == DIRECT_PEDIATRIC
        "direct_pediatric"
    elseif x == MIXED_PEDIATRIC_WITH_NEONATAL_SUBGROUP
        "mixed_pediatric_with_neonatal_subgroup"
    elseif x == PEDIATRIC_NOT_NEONATAL_FOR_NEONATAL_QUESTION
        "pediatric_but_not_neonatal_for_neonatal_question"
    elseif x == ADULT_EXTRAPOLATED_TO_PEDIATRIC
        "adult_extrapolated_to_pediatric"
    else
        "unusable_for_target_population"
    end
end

enum_label(x::StudyDesign) = begin
    if x == SYSTEMATIC_REVIEW_OR_META_ANALYSIS_OF_RELEVANT_TRIALS
        "systematic_review_or_meta_analysis_of_relevant_trials"
    elseif x == RANDOMIZED_CONTROLLED_TRIAL
        "randomized_controlled_trial"
    elseif x == PROSPECTIVE_COHORT
        "prospective_cohort"
    elseif x == RETROSPECTIVE_COHORT
        "retrospective_cohort"
    elseif x == CASE_CONTROL
        "case_control"
    elseif x == CASE_SERIES_OR_CASE_REPORT
        "case_series_or_case_report"
    else
        "expert_opinion_or_narrative_review"
    end
end

enum_label(x::OutcomeRelevance) = begin
    if x == CRITICAL
        "critical"
    elseif x == IMPORTANT
        "important"
    elseif x == INTERMEDIATE_SURROGATE
        "intermediate_surrogate"
    elseif x == LIMITED_RELEVANCE
        "limited_relevance"
    else
        "not_relevant"
    end
end

enum_label(x::RiskOfBias) = begin
    if x == LOW_BIAS
        "low"
    elseif x == MODERATE_BIAS
        "moderate"
    elseif x == HIGH_BIAS
        "high"
    else
        "critical"
    end
end

enum_label(x::ConsistencyLevel) = begin
    if x == HIGH_CONSISTENCY
        "high"
    elseif x == MODERATE_CONSISTENCY
        "moderate"
    elseif x == LOW_CONSISTENCY
        "low"
    else
        "unknown"
    end
end

enum_label(x::PrecisionLevel) = begin
    if x == HIGH_PRECISION
        "high"
    elseif x == MODERATE_PRECISION
        "moderate"
    elseif x == LOW_PRECISION
        "low"
    else
        "very_low"
    end
end

enum_label(x::CertaintyLevel) = begin
    if x == HIGH_CERTAINTY
        "high"
    elseif x == MODERATE_CERTAINTY
        "moderate"
    elseif x == LOW_CERTAINTY
        "low"
    else
        "very_low"
    end
end

enum_label(x::BenefitHarmBalance) = begin
    if x == CLEARLY_FAVORS_BENEFIT
        "clearly_favors_benefit"
    elseif x == PROBABLY_FAVORS_BENEFIT
        "probably_favors_benefit"
    elseif x == UNCERTAIN_OR_BALANCED
        "uncertain_or_balanced"
    elseif x == PROBABLY_FAVORS_HARM
        "probably_favors_harm"
    else
        "clearly_favors_harm"
    end
end

enum_label(x::FeasibilityLevel) = begin
    if x == HIGH_FEASIBILITY
        "high"
    elseif x == MODERATE_FEASIBILITY
        "moderate"
    elseif x == LOW_FEASIBILITY
        "low"
    else
        "not_feasible"
    end
end

enum_label(x::PreferenceSensitivity) = begin
    if x == LOW_PREFERENCE_SENSITIVITY
        "low"
    elseif x == MODERATE_PREFERENCE_SENSITIVITY
        "moderate"
    else
        "high"
    end
end

enum_label(x::RecommendationStrength) = begin
    if x == STRONG_FOR
        "strong_for"
    elseif x == CONDITIONAL_FOR
        "conditional_for"
    elseif x == CONDITIONAL_AGAINST
        "conditional_against"
    elseif x == STRONG_AGAINST
        "strong_against"
    else
        "insufficient_for_recommendation"
    end
end

const neonatal_critical_outcomes = Set([
    "mortality", "death", "severe_ivh", "ivh", "nec", "necrotizing_enterocolitis",
    "bpd", "bronchopulmonary_dysplasia", "neurodevelopmental_impairment",
    "late_onset_sepsis", "rop", "retinopathy_of_prematurity"
])

const pediatric_critical_outcomes = Set([
    "mortality", "death", "icu_admission", "hospitalization", "serious_adverse_event",
    "neurodevelopmental_impairment", "treatment_failure", "organ_failure", "readmission"
])

function normalize_outcome_label(s::AbstractString)::String
    x = lowercase(strip(s))
    x = replace(x, r"[^\w]+" => "_")
    x = replace(x, r"_+" => "_")
    x = strip(x, '_')
    return x
end

struct ScoredDimension
    label::String
    score::Int
    rationale::String
end

struct PopulationDirectnessAssessment
    target_scope::String
    evidence_scope::String
    directness_level::String
    score::Int
    rationale::String
end

struct GradingResult
    population_directness::PopulationDirectnessAssessment
    study_design::ScoredDimension
    outcome_relevance::ScoredDimension
    risk_of_bias::ScoredDimension
    consistency::ScoredDimension
    precision::ScoredDimension
    extrapolation_flag::Bool
    overall_certainty::ScoredDimension
    summary::String
    grader_confidence::Float64
end

struct RecommendationResult
    recommendation_strength::ScoredDimension
    benefit_harm_balance::ScoredDimension
    feasibility::ScoredDimension
    preference_sensitivity::ScoredDimension
    population_applicability::ScoredDimension
    recommendation_summary::String
    cautions::Vector{String}
    grader_confidence::Float64
end

struct EvidenceTableRow
    citation_id::String
    study_design::String
    population_description::String
    gestational_age_range::Union{Nothing,String}
    sample_size::Union{Nothing,Int}
    intervention::String
    comparator::String
    outcomes::Vector{String}
    key_results::Vector{String}
    harms::Vector{String}
    limitations::Vector{String}
    population_directness::String
    overall_certainty::String
    recommendation_strength::String
end

function _certainty_from_total(total::Int)::CertaintyLevel
    if total >= 18
        HIGH_CERTAINTY
    elseif total >= 13
        MODERATE_CERTAINTY
    elseif total >= 8
        LOW_CERTAINTY
    else
        VERY_LOW_CERTAINTY
    end
end

_certainty_cap(a::CertaintyLevel, b::CertaintyLevel)::CertaintyLevel = CertaintyLevel(min(Int(a), Int(b)))

function _score_recommendation_strength(
    certainty::CertaintyLevel,
    benefit_harm::BenefitHarmBalance,
    feasibility::FeasibilityLevel,
    preference::PreferenceSensitivity,
    applicability::String,
    extrapolation_flag::Bool,
    surrogate_only::Bool
)::RecommendationStrength
    if certainty == VERY_LOW_CERTAINTY && benefit_harm > PROBABLY_FAVORS_HARM
        return INSUFFICIENT_FOR_RECOMMENDATION
    end
    if benefit_harm == CLEARLY_FAVORS_HARM
        return STRONG_AGAINST
    elseif benefit_harm == PROBABLY_FAVORS_HARM
        return CONDITIONAL_AGAINST
    end
    if extrapolation_flag || applicability == "extrapolated"
        if benefit_harm >= PROBABLY_FAVORS_BENEFIT && certainty >= LOW_CERTAINTY
            return CONDITIONAL_FOR
        else
            return INSUFFICIENT_FOR_RECOMMENDATION
        end
    end
    if surrogate_only
        return CONDITIONAL_FOR
    end
    if benefit_harm == CLEARLY_FAVORS_BENEFIT &&
       certainty >= MODERATE_CERTAINTY &&
       feasibility >= MODERATE_FEASIBILITY &&
       preference >= MODERATE_PREFERENCE_SENSITIVITY
        return STRONG_FOR
    end
    if benefit_harm >= PROBABLY_FAVORS_BENEFIT
        return CONDITIONAL_FOR
    end
    return INSUFFICIENT_FOR_RECOMMENDATION
end

function validate_grading_result(g::GradingResult)
    errors = String[]
    if !(0.0 <= g.grader_confidence <= 1.0)
        push!(errors, "grader_confidence must be between 0.0 and 1.0")
    end
    for (name, score, lo, hi) in [
        ("population_directness", g.population_directness.score, 0, 4),
        ("study_design", g.study_design.score, 0, 5),
        ("outcome_relevance", g.outcome_relevance.score, 0, 4),
        ("risk_of_bias", g.risk_of_bias.score, 0, 3),
        ("consistency", g.consistency.score, 0, 3),
        ("precision", g.precision.score, 0, 3),
        ("overall_certainty", g.overall_certainty.score, 0, 3),
    ]
        if score < lo || score > hi
            push!(errors, "$name score must be between $lo and $hi")
        end
    end
    isempty(strip(g.summary)) && push!(errors, "summary must not be empty")
    return errors
end

function validate_recommendation_result(r::RecommendationResult)
    errors = String[]
    if !(0.0 <= r.grader_confidence <= 1.0)
        push!(errors, "grader_confidence must be between 0.0 and 1.0")
    end
    for (name, score, lo, hi) in [
        ("recommendation_strength", r.recommendation_strength.score, -1, 3),
        ("benefit_harm_balance", r.benefit_harm_balance.score, -1, 3),
        ("feasibility", r.feasibility.score, 0, 3),
        ("preference_sensitivity", r.preference_sensitivity.score, 0, 2),
        ("population_applicability", r.population_applicability.score, 0, 2),
    ]
        if score < lo || score > hi
            push!(errors, "$name score must be between $lo and $hi")
        end
    end
    isempty(strip(r.recommendation_summary)) && push!(errors, "recommendation_summary must not be empty")
    return errors
end

function compute_certainty(; target_scope::String, evidence_scope::String, population_directness::PopulationDirectness,
    study_design::StudyDesign, outcome_relevance::OutcomeRelevance, risk_of_bias::RiskOfBias,
    consistency::ConsistencyLevel, precision::PrecisionLevel, extrapolation_flag::Bool,
    rationale_population::String, rationale_study_design::String, rationale_outcome::String,
    rationale_bias::String, rationale_consistency::String, rationale_precision::String,
    summary::String="", grader_confidence::Float64=0.85, surrogate_only::Bool=false)::GradingResult

    total = Int(population_directness) + Int(study_design) + Int(outcome_relevance) + Int(risk_of_bias) + Int(consistency) + Int(precision)
    certainty = _certainty_from_total(total)

    if target_scope == "neonatal" && evidence_scope == "adult"
        certainty = _certainty_cap(certainty, LOW_CERTAINTY)
    end
    if target_scope == "pediatric" && evidence_scope == "adult"
        certainty = _certainty_cap(certainty, LOW_CERTAINTY)
    end
    if risk_of_bias == CRITICAL_BIAS
        certainty = _certainty_cap(certainty, LOW_CERTAINTY)
    end
    if surrogate_only
        certainty = _certainty_cap(certainty, MODERATE_CERTAINTY)
    end
    if extrapolation_flag
        certainty = _certainty_cap(certainty, LOW_CERTAINTY)
    end

    isempty(summary) && (summary = "$(enum_label(certainty))-certainty $(extrapolation_flag ? "extrapolated" : "direct") evidence")
    directness_level = Int(population_directness) >= 4 ? "direct" : Int(population_directness) >= 2 ? "partially_direct" : Int(population_directness) >= 1 ? "extrapolated" : "unusable"

    result = GradingResult(
        PopulationDirectnessAssessment(target_scope, evidence_scope, directness_level, Int(population_directness), rationale_population),
        ScoredDimension(enum_label(study_design), Int(study_design), rationale_study_design),
        ScoredDimension(enum_label(outcome_relevance), Int(outcome_relevance), rationale_outcome),
        ScoredDimension(enum_label(risk_of_bias), Int(risk_of_bias), rationale_bias),
        ScoredDimension(enum_label(consistency), Int(consistency), rationale_consistency),
        ScoredDimension(enum_label(precision), Int(precision), rationale_precision),
        extrapolation_flag,
        ScoredDimension(enum_label(certainty), Int(certainty), "Total score $total with downgrade rules applied"),
        summary,
        grader_confidence
    )

    errors = validate_grading_result(result)
    isempty(errors) || throw(ArgumentError("Invalid grading result: $(join(errors, "; "))"))
    return result
end

function compute_recommendation(grading::GradingResult; benefit_harm::BenefitHarmBalance,
    feasibility::FeasibilityLevel, preference_sensitivity::PreferenceSensitivity,
    applicability_label::String, applicability_score::Int,
    rationale_benefit_harm::String, rationale_feasibility::String,
    rationale_preference::String, rationale_applicability::String,
    surrogate_only::Bool=false, cautions::Vector{String}=String[], grader_confidence::Float64=0.84)::RecommendationResult

    certainty = CertaintyLevel(grading.overall_certainty.score)
    strength = _score_recommendation_strength(certainty, benefit_harm, feasibility, preference_sensitivity, applicability_label, grading.extrapolation_flag, surrogate_only)

    if grading.extrapolation_flag
        push!(cautions, "Evidence is extrapolated and should not be over-generalized.")
    end
    if applicability_label == "direct_neonatal"
        push!(cautions, "Do not generalize to older pediatric populations without direct evidence.")
    elseif applicability_label == "direct_pediatric"
        push!(cautions, "Do not generalize to neonatal populations without direct neonatal evidence.")
    elseif applicability_label == "extrapolated"
        push!(cautions, "Recommendation strength is limited by indirect population applicability.")
    end

    summary = "$(replace(enum_label(strength), '_' => ' ')) recommendation based on $(enum_label(certainty)) certainty evidence"

    result = RecommendationResult(
        ScoredDimension(enum_label(strength), Int(strength), "Derived from certainty=$(enum_label(certainty)), benefit-harm=$(enum_label(benefit_harm)), feasibility=$(enum_label(feasibility))"),
        ScoredDimension(enum_label(benefit_harm), Int(benefit_harm), rationale_benefit_harm),
        ScoredDimension(enum_label(feasibility), Int(feasibility), rationale_feasibility),
        ScoredDimension(enum_label(preference_sensitivity), Int(preference_sensitivity), rationale_preference),
        ScoredDimension(applicability_label, applicability_score, rationale_applicability),
        summary,
        unique(cautions),
        grader_confidence
    )

    errors = validate_recommendation_result(result)
    isempty(errors) || throw(ArgumentError("Invalid recommendation result: $(join(errors, "; "))"))
    if grading.extrapolation_flag && result.recommendation_strength.label == "strong_for"
        throw(ArgumentError("Extrapolated evidence cannot produce strong_for"))
    end
    return result
end

JSON3.StructType(::Type{ScoredDimension}) = JSON3.Struct()
JSON3.StructType(::Type{PopulationDirectnessAssessment}) = JSON3.Struct()
JSON3.StructType(::Type{GradingResult}) = JSON3.Struct()
JSON3.StructType(::Type{RecommendationResult}) = JSON3.Struct()
JSON3.StructType(::Type{EvidenceTableRow}) = JSON3.Struct()

end # module
