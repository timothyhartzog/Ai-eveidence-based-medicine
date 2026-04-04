using JSON3

struct ExtractionOutput
    pmid::String
    population::String
    intervention::String
    comparator::String
    outcomes::Vector{String}
    key_results::String
    confidence::Float64
end

function _require_key(obj, key::Symbol)
    haskey(obj, key) || throw(ArgumentError("missing required key: $(key)"))
    return obj[key]
end

function _validate_exact_keys(raw)
    required = Set([:pmid, :population, :intervention, :comparator, :outcomes, :key_results, :confidence])
    present = Set(Symbol(k) for k in keys(raw))
    present == required || throw(ArgumentError("extraction JSON keys mismatch"))
end

"""Run bounded extraction against a single article and enforce strict structured JSON shape."""
function extract_structured_evidence(client::OllamaClient, model::String, article::PubMedArticle)
    prompt = """
Return strict JSON only with keys:
pmid, population, intervention, comparator, outcomes, key_results, confidence.
Use only the provided title and abstract.
PMID: $(article.pmid)
Title: $(article.title)
Abstract: $(article.abstract)
"""
    system = "You are an extraction assistant. Return only valid JSON with the requested keys."
    raw = chat_json(client, model, prompt; system=system)
    _validate_exact_keys(raw)

    pmid = String(_require_key(raw, :pmid))
    outcomes = [String(v) for v in _require_key(raw, :outcomes)]
    confidence = Float64(_require_key(raw, :confidence))
    0.0 <= confidence <= 1.0 || throw(ArgumentError("confidence must be in [0,1]"))

    return ExtractionOutput(
        pmid,
        String(_require_key(raw, :population)),
        String(_require_key(raw, :intervention)),
        String(_require_key(raw, :comparator)),
        outcomes,
        String(_require_key(raw, :key_results)),
        confidence,
    )
end
