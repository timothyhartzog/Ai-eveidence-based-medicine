function _scope_boost(chunk::ArticleChunk, articles_by_pmid::Dict{String,PubMedArticle}, target_scope::AgeScope)
    article = get(articles_by_pmid, chunk.pmid, nothing)
    article === nothing && return 0.0

    if target_scope == neonatal_scope
        return article.inferred_age_scope == neonatal_scope ? 2.0 : article.inferred_age_scope == pediatric_scope ? 1.0 : 0.0
    elseif target_scope == pediatric_scope
        return article.inferred_age_scope in (pediatric_scope, neonatal_scope) ? 2.0 : 0.0
    end
    return 0.0
end

function _keyword_score(text::String, topic::String)
    words = [w for w in split(lowercase(topic)) if length(w) > 3]
    lower_text = lowercase(text)
    return sum(occursin(w, lower_text) for w in words)
end

"""Rerank chunks deterministically using target-scope applicability and topic keyword overlap."""
function rerank_chunks(
    chunks::Vector{ArticleChunk},
    articles::Vector{PubMedArticle},
    topic::String,
    target_scope::AgeScope;
    top_k::Int=20,
)
    by_pmid = Dict(a.pmid => a for a in articles)
    scored = [(chunk, _scope_boost(chunk, by_pmid, target_scope) + _keyword_score(chunk.text, topic)) for chunk in chunks]
    sorted = sort(scored; by=x -> x[2], rev=true)
    return [x[1] for x in Iterators.take(sorted, min(top_k, length(sorted)))]
end
