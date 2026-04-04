using HTTP
using URIs
using JSON3

const PUBMED_BASE_URL = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils"

struct PubMedClient
    base_url::String
    tool::String
    email::Union{String,Nothing}
    api_key::Union{String,Nothing}
    max_retries::Int
    retry_delay_seconds::Float64
end

PubMedClient(; base_url::String=PUBMED_BASE_URL, tool::String="pediatric-evidence", email::Union{String,Nothing}=nothing,
    api_key::Union{String,Nothing}=nothing, max_retries::Int=3, retry_delay_seconds::Float64=0.5) =
    PubMedClient(base_url, tool, email, api_key, max_retries, retry_delay_seconds)

function _query_params(client::PubMedClient, extra::Dict{String,String})
    params = Dict("tool" => client.tool)
    client.email === nothing || (params["email"] = client.email)
    client.api_key === nothing || (params["api_key"] = client.api_key)
    merge!(params, extra)
    return params
end

function _build_url(client::PubMedClient, endpoint::String, params::Dict{String,String})
    ordered_keys = sort(collect(keys(params)))
    query = join(["$(k)=$(escapeuri(params[k]))" for k in ordered_keys], "&")
    return string(client.base_url, "/", endpoint, "?", query)
end

function _get_with_retries(url::String, max_retries::Int, delay::Float64)
    last_error = nothing
    for attempt in 1:max_retries
        try
            response = HTTP.get(url)
            response.status == 200 && return String(response.body)
            last_error = "status $(response.status)"
        catch err
            last_error = err
        end
        attempt < max_retries && sleep(delay)
    end
    throw(ArgumentError("PubMed request failed after $(max_retries) retries: $(last_error)"))
end

"""Run PubMed ESearch and return raw JSON body + parsed PMIDs."""
function esearch(client::PubMedClient, term::String; retmax::Int=20)
    params = _query_params(client, Dict(
        "db" => "pubmed",
        "term" => term,
        "retmode" => "json",
        "retmax" => string(retmax),
    ))
    body = _get_with_retries(_build_url(client, "esearch.fcgi", params), client.max_retries, client.retry_delay_seconds)
    parsed = JSON3.read(body)
    idlist = [String(v) for v in parsed[:esearchresult][:idlist]]
    return body, idlist
end

"""Run PubMed ESummary and return raw JSON body."""
function esummary(client::PubMedClient, pmids::Vector{String})
    ids = join(pmids, ",")
    params = _query_params(client, Dict(
        "db" => "pubmed",
        "id" => ids,
        "retmode" => "json",
    ))
    return _get_with_retries(_build_url(client, "esummary.fcgi", params), client.max_retries, client.retry_delay_seconds)
end

"""Run PubMed EFetch and return raw XML body."""
function efetch(client::PubMedClient, pmids::Vector{String})
    ids = join(pmids, ",")
    params = _query_params(client, Dict(
        "db" => "pubmed",
        "id" => ids,
        "retmode" => "xml",
    ))
    return _get_with_retries(_build_url(client, "efetch.fcgi", params), client.max_retries, client.retry_delay_seconds)
end
