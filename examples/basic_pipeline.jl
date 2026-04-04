using PediatricEvidence

client = PubMedClient()
ollama = OllamaClient()

output = run_review_pipeline(
    "caffeine apnea prematurity";
    target_scope=neonatal_scope,
    pubmed_client=client,
    ollama_client=ollama,
    embedding_model="nomic-embed-text",
    retmax=5,
)

println("PMIDs: ", output.pmids)
println("Articles: ", length(output.articles))
println("Chunks: ", length(output.chunks))
println("Top reranked chunk IDs: ", [c.chunk_id for c in output.reranked_chunks[1:min(end, 5)]])
