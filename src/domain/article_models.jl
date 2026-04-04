"""Target age scope for review and ranking workflows."""
@enum AgeScope begin
    neonatal_scope
    pediatric_scope
    mixed_scope
    adult_scope
    unknown_scope
end

struct PubMedAuthor
    lastname::String
    forename::String
end

"""Typed representation of parsed PubMed article content."""
struct PubMedArticle
    pmid::String
    title::String
    abstract::String
    journal::String
    year::Union{Int,Nothing}
    publication_types::Vector{String}
    mesh_terms::Vector{String}
    authors::Vector{PubMedAuthor}
    inferred_age_scope::AgeScope
    raw_xml::String
end

"""A chunk generated from article abstract text."""
struct ArticleChunk
    pmid::String
    chunk_id::String
    section::String
    text::String
end

"""Chunk plus embedding vector for retrieval/rerank."""
struct ChunkEmbedding
    chunk::ArticleChunk
    embedding::Vector{Float64}
end

"""Top-level review output for deterministic pipeline execution."""
struct ReviewPipelineOutput
    topic::String
    target_scope::AgeScope
    rewritten_queries::Vector{String}
    pmids::Vector{String}
    raw_search_json::Vector{String}
    raw_summary_json::String
    raw_fetch_xml::Vector{String}
    articles::Vector{PubMedArticle}
    chunks::Vector{ArticleChunk}
    chunk_embeddings::Vector{ChunkEmbedding}
    reranked_chunks::Vector{ArticleChunk}
end

"""Backward-compatible constructor when ESummary payload is unavailable."""
ReviewPipelineOutput(
    topic::String,
    target_scope::AgeScope,
    rewritten_queries::Vector{String},
    pmids::Vector{String},
    raw_search_json::Vector{String},
    raw_fetch_xml::Vector{String},
    articles::Vector{PubMedArticle},
    chunks::Vector{ArticleChunk},
    chunk_embeddings::Vector{ChunkEmbedding},
    reranked_chunks::Vector{ArticleChunk},
) = ReviewPipelineOutput(
    topic,
    target_scope,
    rewritten_queries,
    pmids,
    raw_search_json,
    "",
    raw_fetch_xml,
    articles,
    chunks,
    chunk_embeddings,
    reranked_chunks,
)
