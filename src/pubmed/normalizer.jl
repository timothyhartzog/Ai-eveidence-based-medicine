function infer_age_scope(article::PubMedArticle)::AgeScope
    text = lowercase(join(vcat([article.title, article.abstract], article.mesh_terms), " "))

    if occursin("neonat", text) || occursin("newborn", text) || occursin("preterm", text) || occursin("nicu", text)
        return neonatal_scope
    elseif occursin("infant", text) || occursin("child", text) || occursin("adolesc", text) || occursin("pediatric", text)
        return pediatric_scope
    elseif occursin("adult", text)
        return adult_scope
    else
        return unknown_scope
    end
end

"""Return articles with inferred age scope populated in a deterministic way."""
function normalize_articles(articles::Vector{PubMedArticle})
    PubMedArticle[
        PubMedArticle(
            a.pmid,
            strip(a.title),
            strip(a.abstract),
            strip(a.journal),
            a.year,
            unique(a.publication_types),
            unique(a.mesh_terms),
            a.authors,
            infer_age_scope(a),
            a.raw_xml,
        ) for a in articles
    ]
end
