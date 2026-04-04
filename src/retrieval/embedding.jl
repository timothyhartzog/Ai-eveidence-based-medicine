"""Embed chunk texts using Ollama embeddings and return typed chunk embeddings."""
function embed_chunks(client::OllamaClient, model::String, chunks::Vector{ArticleChunk})
    texts = [c.text for c in chunks]
    vectors = embed_texts(client, model, texts)
    length(vectors) == length(chunks) || throw(ArgumentError("embedding output count mismatch"))
    return [ChunkEmbedding(chunks[i], vectors[i]) for i in eachindex(chunks)]
end
