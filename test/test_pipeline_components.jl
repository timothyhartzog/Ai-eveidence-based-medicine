using PediatricEvidence
using Test

const SAMPLE_XML = """
<PubmedArticleSet>
  <PubmedArticle>
    <MedlineCitation>
      <PMID>12345</PMID>
      <Article>
        <ArticleTitle>Neonatal ventilation trial</ArticleTitle>
        <Abstract>
          <AbstractText Label=\"BACKGROUND\">Preterm neonates in NICU.</AbstractText>
          <AbstractText Label=\"RESULTS\">Reduced mortality and IVH.</AbstractText>
        </Abstract>
        <Journal><Title>Test Journal</Title></Journal>
        <PublicationTypeList><PublicationType>Randomized Controlled Trial</PublicationType></PublicationTypeList>
      </Article>
      <MeshHeadingList><MeshHeading><DescriptorName>Infant, Newborn</DescriptorName></MeshHeading></MeshHeadingList>
    </MedlineCitation>
    <PubmedData><History><PubMedPubDate><Year>2024</Year></PubMedPubDate></History></PubmedData>
  </PubmedArticle>
</PubmedArticleSet>
"""

@testset "pipeline components" begin
    articles = parse_pubmed_xml(SAMPLE_XML)
    @test length(articles) == 1
    @test articles[1].pmid == "12345"
    @test articles[1].inferred_age_scope in (neonatal_scope, mixed_scope)

    normalized = normalize_articles(articles)
    @test normalized[1].inferred_age_scope == neonatal_scope

    chunks = chunk_abstracts(normalized; max_chars=80)
    @test !isempty(chunks)
    @test startswith(chunks[1].chunk_id, "12345_")

    rewritten = rewrite_pubmed_query("noninvasive ventilation", neonatal_scope)
    @test length(rewritten) == 2
    @test occursin("neonate", lowercase(rewritten[1]))
    @test_throws ArgumentError rewrite_pubmed_query("   ", neonatal_scope)

    reranked = rerank_chunks(chunks, normalized, "mortality preterm", neonatal_scope; top_k=1)
    @test length(reranked) == 1
    @test reranked[1].pmid == "12345"
end
