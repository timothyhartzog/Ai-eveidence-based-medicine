using PediatricEvidence
using Test

@testset "hardening validators and health checks" begin
    output = ReviewPipelineOutput(
        "topic",
        neonatal_scope,
        ["q1"],
        ["1"],
        ["{\"esearchresult\":{\"count\":\"1\",\"idlist\":[\"1\"]}}"],
        "{\"result\":{}}",
        ["<xml/>"],
        [PubMedArticle("1", "t", "a", "j", 2024, String[], String[], PubMedAuthor[], neonatal_scope, "<xml/>")],
        [ArticleChunk("1", "1_001", "abstract", "text")],
        [ChunkEmbedding(ArticleChunk("1", "1_001", "abstract", "text"), [0.1, 0.2])],
        [ArticleChunk("1", "1_001", "abstract", "text")],
    )

    issues = validate_pipeline_output(output)
    @test isempty(issues)

    fingerprint = audit_fingerprint(output)
    @test length(fingerprint) == 40

    bad_output = ReviewPipelineOutput(
        "",
        neonatal_scope,
        ["q1"],
        ["1", "1"],
        String[],
        String[],
        PubMedArticle[],
        [ArticleChunk("missing", "x", "abstract", "text")],
        ChunkEmbedding[],
        [ArticleChunk("z", "z", "abstract", "text")],
    )
    @test !isempty(validate_pipeline_output(bad_output))

    pubmed_ok = check_pubmed_health(PubMedClient(); perform_network=false)
    ollama_ok = check_ollama_health(OllamaClient(); perform_network=false)
    @test pubmed_ok.ok
    @test ollama_ok.ok

    report = hardening_report(PubMedClient(), OllamaClient(); perform_network=false)
    @test length(report) == 2

    @test !check_pubmed_health(PubMedClient(base_url="invalid"); perform_network=false).ok
    @test !check_ollama_health(OllamaClient(base_url="invalid"); perform_network=false).ok
end
