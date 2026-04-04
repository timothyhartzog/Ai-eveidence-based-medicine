using DataFrames

"""Build dashboard-friendly status metrics from a deterministic pipeline run."""
function pipeline_status_view(output::ReviewPipelineOutput)
    Dict(
        :topic => output.topic,
        :target_scope => string(output.target_scope),
        :queries_count => length(output.rewritten_queries),
        :unique_pmids => length(output.pmids),
        :articles_parsed => length(output.articles),
        :chunks_generated => length(output.chunks),
        :chunks_reranked => length(output.reranked_chunks),
    )
end

"""Filter evidence table rows for dashboard exploration widgets."""
function evidence_table_explorer(
    rows::Vector{EvidenceTableRow};
    population::Union{Nothing,String}=nothing,
    design::Union{Nothing,String}=nothing,
    certainty::Union{Nothing,String}=nothing,
)
    filtered = filter_evidence_rows(rows; population=population, design=design, certainty=certainty)
    return evidence_table_dataframe(filtered)
end

"""Create PRISMA metrics view as key-value DataFrame for tabular widgets."""
function prisma_metrics_view(flow::PrismaFlow)
    DataFrame(
        metric=[
            "total_records_retrieved",
            "duplicates_removed",
            "records_screened",
            "records_excluded",
            "studies_included",
        ],
        value=[
            flow.total_records_retrieved,
            flow.duplicates_removed,
            flow.records_screened,
            flow.records_excluded,
            flow.studies_included,
        ],
    )
end

"""Create neonatal vs pediatric age-scope distribution for dashboard charts."""
function age_scope_distribution(articles::Vector{PubMedArticle})
    buckets = Dict(
        "neonatal_scope" => 0,
        "pediatric_scope" => 0,
        "mixed_scope" => 0,
        "adult_scope" => 0,
        "unknown_scope" => 0,
    )
    for article in articles
        key = string(article.inferred_age_scope)
        buckets[key] = get(buckets, key, 0) + 1
    end
    keys_sorted = collect(keys(buckets))
    sort!(keys_sorted)
    return DataFrame(scope=keys_sorted, count=[buckets[k] for k in keys_sorted])
end
