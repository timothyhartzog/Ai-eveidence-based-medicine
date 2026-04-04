using PediatricEvidence
using Test
using SQLite

@testset "persistence + evidence table" begin
    grading = build_grading_output(
        target_scope=neonatal_target,
        evidence_scope=neonatal_evidence,
        population_directness=direct_neonatal,
        study_design=randomized_controlled_trial,
        outcome_relevance=critical,
        risk_of_bias=low_bias,
        consistency=high_consistency,
        precision=high_precision,
        summary="high quality neonatal trial",
        rationale=Dict("why" => "direct RCT"),
        grader_confidence=0.95,
    )

    recommendation = build_recommendation_output(
        grading,
        recommendation_strength=strong_for,
        benefit_harm_balance=clearly_favors_benefit,
        feasibility=high_feasibility,
        preference_sensitivity=low_preference_sensitivity,
        recommendation_summary="strong recommendation for neonatal use",
        cautions=String[],
        rationale=Dict("reason" => "high certainty + direct applicability"),
        grader_confidence=0.9,
    )

    grow = grading_row(grading)
    rrow = recommendation_row(recommendation)
    @test grow[:overall_certainty_score] == 4
    @test rrow[:recommendation_strength_label] == "strong_for"

    rows = [EvidenceTableRow(
        "PMID:12345",
        "randomized_controlled_trial",
        "preterm neonates",
        "24-32 weeks",
        180,
        "intervention A",
        "standard care",
        ["mortality", "ivh"],
        "improved mortality",
        "none reported",
        "single-region",
        "direct_neonatal",
        "high_certainty",
        "strong_for",
    )]
    df = evidence_table_dataframe(rows)
    @test nrow(df) == 1
    filtered = filter_evidence_rows(rows; population="direct_neonatal", certainty="high_certainty")
    @test length(filtered) == 1

    mktempdir() do d
        csv_path = joinpath(d, "table.csv")
        json_path = joinpath(d, "table.json")
        @test write_evidence_csv(csv_path, rows) == csv_path
        @test write_evidence_json(json_path, rows) == json_path
        @test isfile(csv_path)
        @test isfile(json_path)
    end

    db = SQLite.DB()
    SQLite.execute(db, "CREATE TABLE appraisals (id INTEGER PRIMARY KEY, population_directness_label TEXT, population_directness_score INTEGER, study_design_label TEXT, study_design_score INTEGER, outcome_relevance_label TEXT, outcome_relevance_score INTEGER, risk_of_bias_label TEXT, risk_of_bias_score INTEGER, consistency_label TEXT, consistency_score INTEGER, precision_label TEXT, precision_score INTEGER, extrapolation_flag INTEGER, overall_certainty_label TEXT, overall_certainty_score INTEGER, grading_rationale_json TEXT, grading_downgrade_reasons_json TEXT, grader_confidence REAL, recommendation_strength_label TEXT, recommendation_strength_score INTEGER, benefit_harm_balance_label TEXT, benefit_harm_balance_score INTEGER, feasibility_label TEXT, feasibility_score INTEGER, preference_sensitivity_label TEXT, preference_sensitivity_score INTEGER, population_applicability_label TEXT, population_applicability_score INTEGER, recommendation_summary TEXT, recommendation_cautions_json TEXT, recommendation_rationale_json TEXT, recommendation_confidence REAL)")
    save_appraisal!(db, 1, grading, recommendation)
    count = first(SQLite.execute(db, "SELECT COUNT(*) FROM appraisals"))[1]
    @test count == 1
    SQLite.close(db)
end
