population_directness_score(level::PopulationMatch)::Int = if level in (direct_neonatal, direct_pediatric)
    4
elseif level == mixed_or_partial_match
    3
elseif level == pediatric_non_neonatal_for_neonatal_question
    2
elseif level == extrapolated
    1
else
    0
end

study_design_score(label::StudyDesign)::Int = if label == systematic_review_or_meta_analysis_of_relevant_trials
    5
elseif label == randomized_controlled_trial
    4
elseif label == prospective_cohort
    3
elseif label in (retrospective_cohort, case_control)
    2
elseif label == case_series_or_case_report
    1
else
    0
end

outcome_relevance_score(label::OutcomeRelevance)::Int = if label == critical
    4
elseif label == important
    3
elseif label == intermediate_surrogate
    2
elseif label == limited_relevance
    1
else
    0
end

risk_of_bias_score(label::RiskOfBias)::Int = if label == low_bias
    3
elseif label == moderate_bias
    2
elseif label == high_bias
    1
else
    0
end

consistency_score(label::ConsistencyLevel)::Int = if label == high_consistency
    3
elseif label == moderate_consistency
    2
elseif label == low_consistency
    1
else
    0
end

precision_score(label::PrecisionLevel)::Int = if label == high_precision
    3
elseif label == moderate_precision
    2
elseif label == low_precision
    1
else
    0
end

certainty_score(label::CertaintyLevel)::Int = if label == high_certainty
    4
elseif label == moderate_certainty
    3
elseif label == low_certainty
    2
else
    1
end

function _base_certainty(total::Int)::CertaintyLevel
    if total >= 18
        return high_certainty
    elseif total >= 13
        return moderate_certainty
    elseif total >= 8
        return low_certainty
    end
    return very_low_certainty
end

function _apply_certainty_caps(
    certainty::CertaintyLevel,
    target_scope::TargetScope,
    evidence_scope::EvidenceScope,
    risk_of_bias::RiskOfBias,
    surrogate_only_outcomes::Bool,
    unresolved_indirectness::Bool,
)
    capped = certainty
    reasons = String[]

    if risk_of_bias == critical_bias
        if certainty in (high_certainty, moderate_certainty)
            push!(reasons, "critical risk of bias caps certainty at low")
        end
        capped = min(capped, low_certainty)
    end

    if evidence_scope == adult_evidence
        if target_scope == neonatal_target || target_scope == pediatric_target
            if certainty in (high_certainty, moderate_certainty)
                push!(reasons, "adult-only evidence for child target caps certainty at low")
            end
            capped = min(capped, low_certainty)
        end
    end

    if surrogate_only_outcomes
        if certainty == high_certainty
            push!(reasons, "surrogate-only outcomes cap certainty at moderate")
        end
        capped = min(capped, moderate_certainty)
    end

    if unresolved_indirectness
        if certainty == high_certainty
            push!(reasons, "unresolved indirectness caps certainty at moderate")
        end
        capped = min(capped, moderate_certainty)
    end

    return capped, reasons
end

function validation_errors(grading::GradingOutput)
    errors = String[]

    grading.population_directness_score == population_directness_score(grading.population_directness) ||
        push!(errors, "population_directness_score must match enum mapping")
    grading.study_design_score == study_design_score(grading.study_design) ||
        push!(errors, "study_design_score must match enum mapping")
    grading.outcome_relevance_score == outcome_relevance_score(grading.outcome_relevance) ||
        push!(errors, "outcome_relevance_score must match enum mapping")
    grading.risk_of_bias_score == risk_of_bias_score(grading.risk_of_bias) ||
        push!(errors, "risk_of_bias_score must match enum mapping")
    grading.consistency_score == consistency_score(grading.consistency) ||
        push!(errors, "consistency_score must match enum mapping")
    grading.precision_score == precision_score(grading.precision) ||
        push!(errors, "precision_score must match enum mapping")

    0 <= grading.population_directness_score <= 4 || push!(errors, "population_directness_score out of bounds")
    0 <= grading.study_design_score <= 5 || push!(errors, "study_design_score out of bounds")
    0 <= grading.outcome_relevance_score <= 4 || push!(errors, "outcome_relevance_score out of bounds")
    0 <= grading.risk_of_bias_score <= 3 || push!(errors, "risk_of_bias_score out of bounds")
    0 <= grading.consistency_score <= 3 || push!(errors, "consistency_score out of bounds")
    0 <= grading.precision_score <= 3 || push!(errors, "precision_score out of bounds")

    if grading.evidence_scope == adult_evidence && grading.overall_certainty in (high_certainty, moderate_certainty)
        push!(errors, "adult-only evidence must be capped at low certainty")
    end
    if grading.risk_of_bias == critical_bias && grading.overall_certainty in (high_certainty, moderate_certainty)
        push!(errors, "critical bias must cap certainty at low")
    end
    if grading.surrogate_only_outcomes && grading.overall_certainty == high_certainty
        push!(errors, "surrogate-only outcomes must cap certainty at moderate")
    end

    return errors
end

function build_grading_output(
    ;
    target_scope::TargetScope,
    evidence_scope::EvidenceScope,
    population_directness::PopulationMatch,
    study_design::StudyDesign,
    outcome_relevance::OutcomeRelevance,
    risk_of_bias::RiskOfBias,
    consistency::ConsistencyLevel,
    precision::PrecisionLevel,
    surrogate_only_outcomes::Bool=false,
    unresolved_indirectness::Bool=false,
    extrapolation_flag::Bool=false,
    summary::String,
    rationale::Dict{String,String},
    grader_confidence::Float64,
)
    p = population_directness_score(population_directness)
    s = study_design_score(study_design)
    o = outcome_relevance_score(outcome_relevance)
    r = risk_of_bias_score(risk_of_bias)
    c = consistency_score(consistency)
    pr = precision_score(precision)

    base = _base_certainty(p + s + o + r + c + pr)
    capped, reasons = _apply_certainty_caps(
        base,
        target_scope,
        evidence_scope,
        risk_of_bias,
        surrogate_only_outcomes,
        unresolved_indirectness,
    )

    grading = GradingOutput(
        target_scope,
        evidence_scope,
        population_directness,
        p,
        study_design,
        s,
        outcome_relevance,
        o,
        risk_of_bias,
        r,
        consistency,
        c,
        precision,
        pr,
        extrapolation_flag,
        surrogate_only_outcomes,
        capped,
        certainty_score(capped),
        summary,
        rationale,
        reasons,
        grader_confidence,
    )

    errors = validation_errors(grading)
    isempty(errors) || throw(ArgumentError(join(errors, "; ")))
    return grading
end
