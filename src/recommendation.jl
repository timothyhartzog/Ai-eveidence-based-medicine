recommendation_strength_score(label::RecommendationStrength)::Int = if label == strong_for
    3
elseif label == conditional_for
    2
elseif label == conditional_against
    1
elseif label == strong_against
    0
else
    -1
end

benefit_harm_score(label::BenefitHarmBalance)::Int = if label == clearly_favors_benefit
    3
elseif label == probably_favors_benefit
    2
elseif label == uncertain_or_balanced
    1
elseif label == probably_favors_harm
    0
else
    -1
end

feasibility_score(label::FeasibilityLevel)::Int = if label == high_feasibility
    3
elseif label == moderate_feasibility
    2
elseif label == low_feasibility
    1
else
    0
end

preference_sensitivity_score(label::PreferenceSensitivity)::Int = if label == low_preference_sensitivity
    2
elseif label == moderate_preference_sensitivity
    1
else
    0
end

population_applicability_score(level::PopulationMatch)::Int = if level in (direct_neonatal, direct_pediatric)
    2
elseif level == mixed_or_partial_match
    1
else
    0
end

function validation_errors(recommendation::RecommendationOutput)
    errors = String[]

    recommendation.recommendation_strength_score == recommendation_strength_score(recommendation.recommendation_strength) ||
        push!(errors, "recommendation_strength_score must match enum mapping")
    recommendation.benefit_harm_balance_score == benefit_harm_score(recommendation.benefit_harm_balance) ||
        push!(errors, "benefit_harm_balance_score must match enum mapping")
    recommendation.feasibility_score == feasibility_score(recommendation.feasibility) ||
        push!(errors, "feasibility_score must match enum mapping")
    recommendation.preference_sensitivity_score == preference_sensitivity_score(recommendation.preference_sensitivity) ||
        push!(errors, "preference_sensitivity_score must match enum mapping")
    recommendation.population_applicability_score == population_applicability_score(recommendation.population_applicability) ||
        push!(errors, "population_applicability_score must match enum mapping")

    -1 <= recommendation.recommendation_strength_score <= 3 || push!(errors, "recommendation_strength_score out of bounds")
    -1 <= recommendation.benefit_harm_balance_score <= 3 || push!(errors, "benefit_harm_balance_score out of bounds")
    0 <= recommendation.feasibility_score <= 3 || push!(errors, "feasibility_score out of bounds")
    0 <= recommendation.preference_sensitivity_score <= 2 || push!(errors, "preference_sensitivity_score out of bounds")
    0 <= recommendation.population_applicability_score <= 2 || push!(errors, "population_applicability_score out of bounds")

    if recommendation.population_applicability == extrapolated && recommendation.recommendation_strength == strong_for
        push!(errors, "extrapolated evidence cannot produce strong_for recommendation")
    end

    return errors
end

function build_recommendation_output(
    grading::GradingOutput;
    recommendation_strength::RecommendationStrength,
    benefit_harm_balance::BenefitHarmBalance,
    feasibility::FeasibilityLevel,
    preference_sensitivity::PreferenceSensitivity,
    recommendation_summary::String,
    cautions::Vector{String},
    rationale::Dict{String,String},
    grader_confidence::Float64,
)
    applicability = grading.population_directness

    if applicability == extrapolated && recommendation_strength == strong_for
        throw(ArgumentError("extrapolated evidence cannot produce strong_for recommendation"))
    end

    if grading.overall_certainty == very_low_certainty && recommendation_strength == strong_for
        throw(ArgumentError("very low certainty evidence cannot produce strong_for recommendation"))
    end

    recommendation = RecommendationOutput(
        recommendation_strength,
        recommendation_strength_score(recommendation_strength),
        benefit_harm_balance,
        benefit_harm_score(benefit_harm_balance),
        feasibility,
        feasibility_score(feasibility),
        preference_sensitivity,
        preference_sensitivity_score(preference_sensitivity),
        applicability,
        population_applicability_score(applicability),
        recommendation_summary,
        cautions,
        rationale,
        grader_confidence,
    )

    errors = validation_errors(recommendation)
    isempty(errors) || throw(ArgumentError(join(errors, "; ")))
    return recommendation
end
