using PediatricEvidence
using Test
using JSON3

@testset "dashboard view models and json routes" begin
    articles = [
        PubMedArticle("1", "neonatal title", "nicu care", "J", 2024, String[], String[], PubMedAuthor[], neonatal_scope, "<xml/>"),
        PubMedArticle("2", "pediatric title", "child cohort", "J", 2023, String[], String[], PubMedAuthor[], pediatric_scope, "<xml/>"),
    ]

    output = ReviewPipelineOutput(
        "ventilation",
        neonatal_scope,
        ["q1", "q2"],
        ["1", "2"],
        ["{\"esearchresult\":{\"count\":\"2\",\"idlist\":[\"1\",\"2\"]}}"],
        ["<xml/>"],
        articles,
        ArticleChunk[],
        ChunkEmbedding[],
        ArticleChunk[],
    )

    status = pipeline_status_view(output)
    @test status[:unique_pmids] == 2

    rows = [
        EvidenceTableRow("PMID:1", "randomized_controlled_trial", "preterm", "24-32", 100, "A", "B", ["mortality"], "benefit", "none", "single center", "direct_neonatal", "moderate_certainty", "conditional_for"),
        EvidenceTableRow("PMID:2", "prospective_cohort", "children", "n/a", 80, "A", "B", ["length_of_stay"], "trend", "none", "confounding", "direct_pediatric", "low_certainty", "conditional_for"),
    ]

    explorer = evidence_table_explorer(rows; population="direct_neonatal")
    @test nrow(explorer) == 1

    flow = build_prisma_flow(
        total_records_retrieved=10,
        duplicates_removed=2,
        records_screened=8,
        exclusion_reasons=Dict("wrong population" => 3),
        studies_included=5,
    )
    metrics = prisma_metrics_view(flow)
    @test nrow(metrics) == 5

    dist = age_scope_distribution(articles)
    @test sum(dist.count) == 2

    parsed_status = JSON3.read(dashboard_pipeline_status_json(output))
    @test parsed_status[:queries_count] == 2

    parsed_table = JSON3.read(dashboard_evidence_table_json(rows; certainty="moderate_certainty"))
    @test length(parsed_table) == 1

    parsed_prisma = JSON3.read(dashboard_prisma_json(flow))
    @test length(parsed_prisma) == 5

    parsed_dist = JSON3.read(dashboard_age_distribution_json(articles))
    @test length(parsed_dist) >= 2
end
