using HTTP
using JSON3

struct OllamaClient
    base_url::String
    timeout_seconds::Int
end

OllamaClient(; base_url::String="http://localhost:11434", timeout_seconds::Int=60) =
    OllamaClient(base_url, timeout_seconds)

function _post_json(client::OllamaClient, path::String, payload)
    url = string(client.base_url, path)
    body = JSON3.write(payload)
    response = HTTP.post(
        url,
        ["Content-Type" => "application/json"],
        body;
        readtimeout=client.timeout_seconds,
    )
    response.status == 200 || throw(ArgumentError("Ollama request failed: $(response.status)"))
    return JSON3.read(String(response.body))
end

"""Call Ollama chat API and enforce strict JSON output payload."""
function chat_json(client::OllamaClient, model::String, prompt::String; system::String="")
    payload = Dict(
        "model" => model,
        "stream" => false,
        "format" => "json",
        "messages" => [
            Dict("role" => "system", "content" => system),
            Dict("role" => "user", "content" => prompt),
        ],
    )
    response = _post_json(client, "/api/chat", payload)
    content = String(get(get(response, :message, Dict{Symbol,Any}()), :content, "{}"))
    parsed = try
        JSON3.read(content)
    catch
        throw(ArgumentError("LLM did not return valid JSON"))
    end
    return parsed
end

"""Generate embeddings for provided texts via Ollama embedding endpoint."""
function embed_texts(client::OllamaClient, model::String, texts::Vector{String})
    vectors = Vector{Vector{Float64}}()
    for text in texts
        payload = Dict("model" => model, "prompt" => text)
        response = _post_json(client, "/api/embeddings", payload)
        emb = Vector{Float64}(response[:embedding])
        push!(vectors, emb)
    end
    return vectors
end
