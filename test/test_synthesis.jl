using PediatricEvidence
using Test
using JSON3

@testset "structured synthesis" begin
    grading = build_grading_output(
        target_scope=neonatal_target,
        evidence_scope=neonatal_evidence,
        population_directness=direct_neonatal,
        study_design=randomized_controlled_trial,
        outcome_relevance=critical,
        risk_of_bias=low_bias,
        consistency=high_consistency,
        precision=moderate_precision,
        summary="direct neonatal evidence",
        rationale=Dict("r" => "valid"),
        grader_confidence=0.88,
    )

    recommendation = build_recommendation_output(
        grading,
        recommendation_strength=conditional_for,
        benefit_harm_balance=probably_favors_benefit,
        feasibility=moderate_feasibility,
        preference_sensitivity=moderate_preference_sensitivity,
        recommendation_summary="conditional use",
        cautions=["monitor implementation"],
        rationale=Dict("r" => "indirect uncertainty"),
        grader_confidence=0.81,
    )

    synthesis = synthesize_evidence(
        grading,
        recommendation;
        summary="Moderate-certainty neonatal evidence suggests benefit.",
        evidence_gaps=["limited term infant data"],
        conflicts=["secondary outcomes mixed"],
    )

    @test synthesis.certainty == grading.overall_certainty
    @test synthesis.recommendation == recommendation.recommendation_strength

    payload = JSON3.read(synthesis_json(synthesis))
    @test payload[:applicability] == string(direct_neonatal)
    @test payload[:recommendation] == string(conditional_for)
end
