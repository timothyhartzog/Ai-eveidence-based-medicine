using EzXML

function _node_text_or_empty(node, xpath::String)
    n = findfirst(xpath, node)
    n === nothing && return ""
    return strip(nodecontent(n))
end

function _node_texts(node, xpath::String)
    [strip(nodecontent(n)) for n in findall(xpath, node) if !isempty(strip(nodecontent(n)))]
end

function _parse_year(article_node)
    for path in [".//PubDate/Year", ".//ArticleDate/Year", ".//DateCompleted/Year"]
        y = _node_text_or_empty(article_node, path)
        isempty(y) || return tryparse(Int, y)
    end
    return nothing
end

function _parse_authors(article_node)
    authors = PubMedAuthor[]
    for a in findall(".//Author", article_node)
        last = _node_text_or_empty(a, "./LastName")
        fore = _node_text_or_empty(a, "./ForeName")
        (!isempty(last) || !isempty(fore)) && push!(authors, PubMedAuthor(last, fore))
    end
    return authors
end

function _infer_age_scope(title::String, abstract_text::String, mesh_terms::Vector{String})
    text = lowercase(join(vcat([title, abstract_text], mesh_terms), " "))
    has_neonatal = occursin("neonat", text) || occursin("newborn", text) || occursin("preterm", text) || occursin("nicu", text)
    has_pediatric = occursin("pediatric", text) || occursin("child", text) || occursin("adolesc", text) || occursin("infant", text)
    has_adult = occursin("adult", text)

    if has_neonatal && has_pediatric
        return mixed_scope
    elseif has_neonatal
        return neonatal_scope
    elseif has_pediatric
        return pediatric_scope
    elseif has_adult
        return adult_scope
    end
    return unknown_scope
end

"""Parse PubMed EFetch XML into typed PubMedArticle records."""
function parse_pubmed_xml(xml::String)
    doc = EzXML.readxml(IOBuffer(xml))
    results = PubMedArticle[]

    for n in findall("//PubmedArticle", doc)
        pmid = _node_text_or_empty(n, ".//PMID")
        title = _node_text_or_empty(n, ".//ArticleTitle")
        abstract_parts = _node_texts(n, ".//Abstract/AbstractText")
        abstract_text = join(abstract_parts, "\n")
        journal = _node_text_or_empty(n, ".//Journal/Title")
        year = _parse_year(n)
        pub_types = _node_texts(n, ".//PublicationType")
        mesh_terms = _node_texts(n, ".//MeshHeading/DescriptorName")
        authors = _parse_authors(n)
        inferred_scope = _infer_age_scope(title, abstract_text, mesh_terms)

        push!(results, PubMedArticle(
            pmid,
            title,
            abstract_text,
            journal,
            year,
            pub_types,
            mesh_terms,
            authors,
            inferred_scope,
            xml,
        ))
    end

    return results
end
