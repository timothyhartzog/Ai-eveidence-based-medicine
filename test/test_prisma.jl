using PediatricEvidence
using Test

@testset "prisma tracker" begin
    output = ReviewPipelineOutput(
        "test topic",
        neonatal_scope,
        ["q1", "q2"],
        ["1", "2", "3"],
        [
            "{\"esearchresult\":{\"count\":\"4\",\"idlist\":[\"1\",\"2\"]}}",
            "{\"esearchresult\":{\"count\":\"3\",\"idlist\":[\"2\",\"3\"]}}",
        ],
        String[],
        PubMedArticle[],
        ArticleChunk[],
        ChunkEmbedding[],
        ArticleChunk[],
    )

    flow = prisma_from_pipeline(output; exclusion_reasons=Dict("wrong population" => 1, "duplicate cohort" => 1))
    @test flow.total_records_retrieved == 7
    @test flow.duplicates_removed == 4
    @test flow.records_screened == 3
    @test flow.records_excluded == 2

    direct = build_prisma_flow(
        total_records_retrieved=10,
        duplicates_removed=2,
        records_screened=8,
        exclusion_reasons=Dict("not pediatric" => 3),
        studies_included=5,
    )
    @test direct.records_excluded == 3
    @test_throws ArgumentError build_prisma_flow(
        total_records_retrieved=5,
        duplicates_removed=0,
        records_screened=2,
        exclusion_reasons=Dict{String,Int}(),
        studies_included=3,
    )
end
