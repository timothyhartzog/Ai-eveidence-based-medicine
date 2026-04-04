using JSON3

function dashboard_pipeline_status_json(output::ReviewPipelineOutput)
    JSON3.write(pipeline_status_view(output))
end

function dashboard_evidence_table_json(
    rows::Vector{EvidenceTableRow};
    population::Union{Nothing,String}=nothing,
    design::Union{Nothing,String}=nothing,
    certainty::Union{Nothing,String}=nothing,
)
    df = evidence_table_explorer(rows; population=population, design=design, certainty=certainty)
    records = [Dict(Symbol(name) => row[i] for (i, name) in enumerate(names(df))) for row in eachrow(df)]
    JSON3.write(records)
end

function dashboard_prisma_json(flow::PrismaFlow)
    df = prisma_metrics_view(flow)
    records = [Dict(Symbol(name) => row[i] for (i, name) in enumerate(names(df))) for row in eachrow(df)]
    JSON3.write(records)
end

function dashboard_age_distribution_json(articles::Vector{PubMedArticle})
    df = age_scope_distribution(articles)
    records = [Dict(Symbol(name) => row[i] for (i, name) in enumerate(names(df))) for row in eachrow(df)]
    JSON3.write(records)
end
