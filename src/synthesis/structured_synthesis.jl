using JSON3

struct SynthesisOutput
    summary::String
    certainty::CertaintyLevel
    recommendation::RecommendationStrength
    evidence_gaps::Vector{String}
    conflicts::Vector{String}
    applicability::PopulationMatch
end

"""
Create synthesis output from structured grading + recommendation inputs only.
This intentionally excludes raw abstracts/XML to keep synthesis bounded and auditable.
"""
function synthesize_evidence(
    grading::GradingOutput,
    recommendation::RecommendationOutput;
    summary::String,
    evidence_gaps::Vector{String}=String[],
    conflicts::Vector{String}=String[],
)
    applicability = recommendation.population_applicability
    applicability == grading.population_directness || throw(ArgumentError("applicability mismatch between grading and recommendation"))

    return SynthesisOutput(
        summary,
        grading.overall_certainty,
        recommendation.recommendation_strength,
        evidence_gaps,
        conflicts,
        applicability,
    )
end

"""Render synthesis output as strict JSON string for downstream pipelines."""
function synthesis_json(output::SynthesisOutput)
    payload = Dict(
        :summary => output.summary,
        :certainty => string(output.certainty),
        :recommendation => string(output.recommendation),
        :evidence_gaps => output.evidence_gaps,
        :conflicts => output.conflicts,
        :applicability => string(output.applicability),
    )
    return JSON3.write(payload)
end
