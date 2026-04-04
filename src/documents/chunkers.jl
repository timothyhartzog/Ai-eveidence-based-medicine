function _section_split(abstract_text::String)
    lines = split(replace(abstract_text, "\r\n" => "\n"), "\n")
    sections = Pair{String,String}[]
    current_section = "abstract"
    buffer = String[]

    for line in lines
        stripped = strip(line)
        if occursin(r"^[A-Z][A-Z ]{2,}:$", stripped)
            if !isempty(buffer)
                push!(sections, current_section => join(buffer, " "))
                empty!(buffer)
            end
            current_section = lowercase(chop(stripped; tail=1))
        elseif !isempty(stripped)
            push!(buffer, stripped)
        end
    end
    !isempty(buffer) && push!(sections, current_section => join(buffer, " "))
    isempty(sections) && push!(sections, "abstract" => strip(abstract_text))
    return sections
end

"""Chunk abstracts while preserving PMID, section metadata, and deterministic chunk IDs."""
function chunk_abstracts(articles::Vector{PubMedArticle}; max_chars::Int=450)
    chunks = ArticleChunk[]
    for article in articles
        sections = _section_split(article.abstract)
        local_idx = 1
        for (section, txt) in sections
            start_idx = 1
            while start_idx <= lastindex(txt)
                end_idx = min(lastindex(txt), start_idx + max_chars - 1)
                snippet = strip(txt[start_idx:end_idx])
                if !isempty(snippet)
                    chunk_id = string(article.pmid, "_", lpad(local_idx, 3, "0"))
                    push!(chunks, ArticleChunk(article.pmid, chunk_id, section, snippet))
                    local_idx += 1
                end
                start_idx = end_idx + 1
            end
        end
    end
    return chunks
end
