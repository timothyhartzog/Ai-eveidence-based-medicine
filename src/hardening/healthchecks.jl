using HTTP

struct ServiceHealth
    service::String
    ok::Bool
    detail::String
end

function _validate_url(url::String)
    startswith(url, "http://") || startswith(url, "https://")
end

function check_pubmed_health(client::PubMedClient; perform_network::Bool=false)
    _validate_url(client.base_url) || return ServiceHealth("pubmed", false, "invalid base_url")
    if !perform_network
        return ServiceHealth("pubmed", true, "configuration valid (network check skipped)")
    end

    try
        url = string(client.base_url, "/esearch.fcgi?db=pubmed&term=test&retmax=1&retmode=json")
        resp = HTTP.get(url)
        return ServiceHealth("pubmed", resp.status == 200, "status $(resp.status)")
    catch err
        return ServiceHealth("pubmed", false, string(err))
    end
end

function check_ollama_health(client::OllamaClient; perform_network::Bool=false)
    _validate_url(client.base_url) || return ServiceHealth("ollama", false, "invalid base_url")
    if !perform_network
        return ServiceHealth("ollama", true, "configuration valid (network check skipped)")
    end

    try
        url = string(client.base_url, "/api/tags")
        resp = HTTP.get(url)
        return ServiceHealth("ollama", resp.status == 200, "status $(resp.status)")
    catch err
        return ServiceHealth("ollama", false, string(err))
    end
end

function hardening_report(pubmed_client::PubMedClient, ollama_client::OllamaClient; perform_network::Bool=false)
    [
        check_pubmed_health(pubmed_client; perform_network=perform_network),
        check_ollama_health(ollama_client; perform_network=perform_network),
    ]
end
