"""Deterministic query rewriting into constrained PubMed query variants."""
function rewrite_pubmed_query(topic::String, target_scope::AgeScope)
    clean_topic = strip(topic)
    scope_filter = if target_scope == neonatal_scope
        "(neonate OR neonatal OR newborn OR preterm OR NICU)"
    elseif target_scope == pediatric_scope
        "(pediatric OR infant OR child OR adolescent)"
    else
        "(infant OR child OR adolescent OR adult)"
    end

    return [
        string("(", clean_topic, ") AND ", scope_filter),
        string("(", clean_topic, ") AND randomized OR cohort AND ", scope_filter),
    ]
end
