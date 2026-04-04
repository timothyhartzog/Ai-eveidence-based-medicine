using SHA

struct ValidationIssue
    field::String
    message::String
end

function validate_pipeline_output(output::ReviewPipelineOutput)
    issues = ValidationIssue[]

    isempty(output.topic) && push!(issues, ValidationIssue("topic", "topic must not be empty"))
    length(unique(output.pmids)) == length(output.pmids) ||
        push!(issues, ValidationIssue("pmids", "pmids must be unique in pipeline output"))

    article_pmids = Set(a.pmid for a in output.articles)
    for chunk in output.chunks
        in(chunk.pmid, article_pmids) || push!(issues, ValidationIssue("chunks", "chunk PMID not found in parsed articles"))
    end

    length(output.chunk_embeddings) <= length(output.chunks) ||
        push!(issues, ValidationIssue("chunk_embeddings", "embedding count cannot exceed chunk count"))

    for c in output.reranked_chunks
        any(x -> x.chunk_id == c.chunk_id, output.chunks) ||
            push!(issues, ValidationIssue("reranked_chunks", "reranked chunk must originate from chunk list"))
    end

    return issues
end

"""Stable audit fingerprint for a pipeline output to support deterministic traceability."""
function audit_fingerprint(output::ReviewPipelineOutput)
    payload = join([
        output.topic,
        string(output.target_scope),
        join(output.rewritten_queries, "|"),
        join(output.pmids, ","),
        string(length(output.articles)),
        string(length(output.chunks)),
        string(length(output.reranked_chunks)),
    ], "::")
    bytes2hex(sha1(payload))
end
