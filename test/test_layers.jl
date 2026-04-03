@testset "Pediatric evidence grading and recommendation" begin
    @testset "direct neonatal RCT" begin
        grading = build_grading_output(
            target_scope=neonatal_target,
            evidence_scope=neonatal_evidence,
            population_directness=direct_neonatal,
            study_design=randomized_controlled_trial,
            outcome_relevance=critical,
            risk_of_bias=low_bias,
            consistency=high_consistency,
            precision=moderate_precision,
            summary="Moderate/high certainty direct neonatal evidence",
            rationale=Dict("population" => "neonatal NICU RCT"),
            grader_confidence=0.92,
        )
        @test grading.overall_certainty in (high_certainty, moderate_certainty)
        @test isempty(grading.downgrade_reasons)
    end

    @testset "direct pediatric cohort" begin
        grading = build_grading_output(
            target_scope=pediatric_target,
            evidence_scope=pediatric_evidence,
            population_directness=direct_pediatric,
            study_design=prospective_cohort,
            outcome_relevance=important,
            risk_of_bias=moderate_bias,
            consistency=moderate_consistency,
            precision=moderate_precision,
            summary="Direct pediatric cohort evidence",
            rationale=Dict("population" => "children only"),
            grader_confidence=0.85,
        )
        @test grading.overall_certainty == moderate_certainty
    end

    @testset "adult extrapolated evidence" begin
        grading = build_grading_output(
            target_scope=pediatric_target,
            evidence_scope=adult_evidence,
            population_directness=extrapolated,
            study_design=randomized_controlled_trial,
            outcome_relevance=critical,
            risk_of_bias=moderate_bias,
            consistency=moderate_consistency,
            precision=high_precision,
            extrapolation_flag=true,
            summary="Adult evidence extrapolated to pediatrics",
            rationale=Dict("population" => "adult ICU to pediatric ICU extrapolation"),
            grader_confidence=0.71,
        )
        @test grading.overall_certainty == low_certainty
        @test any(contains("adult-only evidence") for r in grading.downgrade_reasons)

        @test_throws ArgumentError build_recommendation_output(
            grading,
            recommendation_strength=strong_for,
            benefit_harm_balance=probably_favors_benefit,
            feasibility=moderate_feasibility,
            preference_sensitivity=moderate_preference_sensitivity,
            recommendation_summary="Should fail due to hard rule",
            cautions=String[],
            rationale=Dict("rule" => "hard extrapolation cap"),
            grader_confidence=0.8,
        )
    end

    @testset "surrogate-only outcomes" begin
        grading = build_grading_output(
            target_scope=neonatal_target,
            evidence_scope=neonatal_evidence,
            population_directness=direct_neonatal,
            study_design=systematic_review_or_meta_analysis_of_relevant_trials,
            outcome_relevance=intermediate_surrogate,
            risk_of_bias=low_bias,
            consistency=high_consistency,
            precision=high_precision,
            surrogate_only_outcomes=true,
            summary="Only surrogate outcomes available",
            rationale=Dict("outcomes" => "lab marker only"),
            grader_confidence=0.77,
        )
        @test grading.overall_certainty == moderate_certainty
        @test any(contains("surrogate-only outcomes") for r in grading.downgrade_reasons)
    end

    @testset "high bias study" begin
        grading = build_grading_output(
            target_scope=neonatal_target,
            evidence_scope=neonatal_evidence,
            population_directness=direct_neonatal,
            study_design=retrospective_cohort,
            outcome_relevance=important,
            risk_of_bias=critical_bias,
            consistency=low_consistency,
            precision=low_precision,
            summary="Critical bias limits certainty",
            rationale=Dict("bias" => "major confounding and missing outcomes"),
            grader_confidence=0.66,
        )
        @test grading.overall_certainty == low_certainty
        @test any(contains("critical risk of bias") for r in grading.downgrade_reasons)
    end
end
