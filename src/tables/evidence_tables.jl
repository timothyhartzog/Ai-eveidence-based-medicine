using DataFrames
using CSV
using JSON3

struct EvidenceTableRow
    citation_id::String
    study_design::String
    population_description::String
    gestational_age_range::String
    sample_size::Union{Int,Nothing}
    intervention::String
    comparator::String
    outcomes::Vector{String}
    key_results::String
    harms::String
    limitations::String
    population_directness::String
    overall_certainty::String
    recommendation_strength::String
end

function evidence_table_dataframe(rows::Vector{EvidenceTableRow})
    DataFrame(
        citation_id=[r.citation_id for r in rows],
        study_design=[r.study_design for r in rows],
        population_description=[r.population_description for r in rows],
        gestational_age_range=[r.gestational_age_range for r in rows],
        sample_size=[r.sample_size for r in rows],
        intervention=[r.intervention for r in rows],
        comparator=[r.comparator for r in rows],
        outcomes=[join(r.outcomes, "|") for r in rows],
        key_results=[r.key_results for r in rows],
        harms=[r.harms for r in rows],
        limitations=[r.limitations for r in rows],
        population_directness=[r.population_directness for r in rows],
        overall_certainty=[r.overall_certainty for r in rows],
        recommendation_strength=[r.recommendation_strength for r in rows],
    )
end

function filter_evidence_rows(rows::Vector{EvidenceTableRow}; population::Union{Nothing,String}=nothing, design::Union{Nothing,String}=nothing, certainty::Union{Nothing,String}=nothing)
    filter(rows) do r
        (population === nothing || r.population_directness == population) &&
        (design === nothing || r.study_design == design) &&
        (certainty === nothing || r.overall_certainty == certainty)
    end
end

function write_evidence_csv(path::String, rows::Vector{EvidenceTableRow})
    CSV.write(path, evidence_table_dataframe(rows))
    return path
end

function write_evidence_json(path::String, rows::Vector{EvidenceTableRow})
    payload = [
        Dict(
            :citation_id => r.citation_id,
            :study_design => r.study_design,
            :population_description => r.population_description,
            :gestational_age_range => r.gestational_age_range,
            :sample_size => r.sample_size,
            :intervention => r.intervention,
            :comparator => r.comparator,
            :outcomes => r.outcomes,
            :key_results => r.key_results,
            :harms => r.harms,
            :limitations => r.limitations,
            :population_directness => r.population_directness,
            :overall_certainty => r.overall_certainty,
            :recommendation_strength => r.recommendation_strength,
        ) for r in rows
    ]
    open(path, "w") do io
        write(io, JSON3.write(payload))
    end
    return path
end
