using SQLite
using JSON3

"""Persistence-ready flattened grading payload."""
function grading_row(grading::GradingOutput)
    Dict(
        :population_directness_label => string(grading.population_directness),
        :population_directness_score => grading.population_directness_score,
        :study_design_label => string(grading.study_design),
        :study_design_score => grading.study_design_score,
        :outcome_relevance_label => string(grading.outcome_relevance),
        :outcome_relevance_score => grading.outcome_relevance_score,
        :risk_of_bias_label => string(grading.risk_of_bias),
        :risk_of_bias_score => grading.risk_of_bias_score,
        :consistency_label => string(grading.consistency),
        :consistency_score => grading.consistency_score,
        :precision_label => string(grading.precision),
        :precision_score => grading.precision_score,
        :extrapolation_flag => grading.extrapolation_flag,
        :overall_certainty_label => string(grading.overall_certainty),
        :overall_certainty_score => grading.overall_certainty_score,
        :grading_rationale_json => JSON3.write(grading.rationale),
        :grading_downgrade_reasons_json => JSON3.write(grading.downgrade_reasons),
        :grader_confidence => grading.grader_confidence,
    )
end

"""Persistence-ready flattened recommendation payload."""
function recommendation_row(recommendation::RecommendationOutput)
    Dict(
        :recommendation_strength_label => string(recommendation.recommendation_strength),
        :recommendation_strength_score => recommendation.recommendation_strength_score,
        :benefit_harm_balance_label => string(recommendation.benefit_harm_balance),
        :benefit_harm_balance_score => recommendation.benefit_harm_balance_score,
        :feasibility_label => string(recommendation.feasibility),
        :feasibility_score => recommendation.feasibility_score,
        :preference_sensitivity_label => string(recommendation.preference_sensitivity),
        :preference_sensitivity_score => recommendation.preference_sensitivity_score,
        :population_applicability_label => string(recommendation.population_applicability),
        :population_applicability_score => recommendation.population_applicability_score,
        :recommendation_summary => recommendation.recommendation_summary,
        :recommendation_cautions_json => JSON3.write(recommendation.cautions),
        :recommendation_rationale_json => JSON3.write(recommendation.rationale),
        :recommendation_confidence => recommendation.grader_confidence,
    )
end

"""Insert grading+recommendation payload into appraisals table for a review row id."""
function save_appraisal!(db::SQLite.DB, appraisal_id::Integer, grading::GradingOutput, recommendation::RecommendationOutput)
    row = merge(grading_row(grading), recommendation_row(recommendation))
    columns = [:id; collect(keys(row))]
    params = [appraisal_id; collect(values(row))]
    placeholders = join(fill("?", length(columns)), ",")
    sql = "INSERT OR REPLACE INTO appraisals ($(join(string.(columns), ","))) VALUES ($(placeholders));"
    DBInterface.execute(db, sql, params)
    return nothing
end
