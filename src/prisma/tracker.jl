using JSON3

function build_prisma_flow(
    ;
    total_records_retrieved::Int,
    duplicates_removed::Int,
    records_screened::Int,
    exclusion_reasons::Dict{String,Int},
    studies_included::Int,
)
    records_excluded = sum(values(exclusion_reasons))
    records_screened >= studies_included || throw(ArgumentError("screened records must be >= included studies"))
    return PrismaFlow(
        total_records_retrieved,
        duplicates_removed,
        records_screened,
        records_excluded,
        exclusion_reasons,
        studies_included,
    )
end

"""Build PRISMA flow summary from deterministic pipeline artifacts."""
function prisma_from_pipeline(output::ReviewPipelineOutput; exclusion_reasons::Dict{String,Int}=Dict{String,Int}())
    retrieved = 0
    for raw in output.raw_search_json
        parsed = JSON3.read(raw)
        count_val = tryparse(Int, String(parsed[:esearchresult][:count]))
        retrieved += something(count_val, 0)
    end

    duplicates = max(retrieved - length(output.pmids), 0)
    screened = length(output.pmids)
    included = length(output.articles)

    return build_prisma_flow(
        total_records_retrieved=retrieved,
        duplicates_removed=duplicates,
        records_screened=screened,
        exclusion_reasons=exclusion_reasons,
        studies_included=included,
    )
end
