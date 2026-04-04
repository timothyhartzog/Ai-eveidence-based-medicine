"""Run deterministic review pipeline from topic to reranked abstract chunks."""
function run_review_pipeline(
    topic::String;
    target_scope::AgeScope,
    pubmed_client::PubMedClient=PubMedClient(),
    ollama_client::OllamaClient=OllamaClient(),
    embedding_model::String="nomic-embed-text",
    retmax::Int=20,
)
    rewritten_queries = rewrite_pubmed_query(topic, target_scope)

    raw_searches = String[]
    all_pmids = String[]
    for q in rewritten_queries
        raw, pmids = esearch(pubmed_client, q; retmax=retmax)
        push!(raw_searches, raw)
        append!(all_pmids, pmids)
    end
    pmids = unique(all_pmids)

    raw_xml = isempty(pmids) ? "" : efetch(pubmed_client, pmids)
    raw_fetch_xml = isempty(raw_xml) ? String[] : [raw_xml]

    articles = isempty(raw_xml) ? PubMedArticle[] : parse_pubmed_xml(raw_xml)
    normalized = normalize_articles(articles)
    chunks = chunk_abstracts(normalized)
    chunk_embeddings = isempty(chunks) ? ChunkEmbedding[] : embed_chunks(ollama_client, embedding_model, chunks)
    reranked = rerank_chunks(chunks, normalized, topic, target_scope)

    return ReviewPipelineOutput(
        topic,
        target_scope,
        rewritten_queries,
        pmids,
        raw_searches,
        raw_fetch_xml,
        normalized,
        chunks,
        chunk_embeddings,
        reranked,
    )
end
