# DB persistence layer for grading + recommendation
module GradingRepo

using SQLite
using JSON3
using ..GradingEngine

export create_grading_tables!, insert_grading_result!, insert_recommendation_result!, fetch_grading_result, fetch_recommendation_result, upsert_grading_and_recommendation!

function create_grading_tables!(db::SQLite.DB)
    SQLite.execute(db, "CREATE TABLE IF NOT EXISTS appraisals (id INTEGER PRIMARY KEY, review_id TEXT, citation_id TEXT, grading_json TEXT)")
    SQLite.execute(db, "CREATE TABLE IF NOT EXISTS recommendations (id INTEGER PRIMARY KEY, review_id TEXT, citation_id TEXT, recommendation_json TEXT)")
end

function insert_grading_result!(db, review_id, citation_id, grading)
    SQLite.execute(db, "INSERT INTO appraisals (review_id, citation_id, grading_json) VALUES (?, ?, ?)", (review_id, citation_id, JSON3.write(grading)))
end

function insert_recommendation_result!(db, review_id, citation_id, rec)
    SQLite.execute(db, "INSERT INTO recommendations (review_id, citation_id, recommendation_json) VALUES (?, ?, ?)", (review_id, citation_id, JSON3.write(rec)))
end

function fetch_grading_result(db, review_id, citation_id)
    rows = DBInterface.execute(db, "SELECT grading_json FROM appraisals WHERE review_id=? AND citation_id=?", (review_id, citation_id))
    data = collect(rows)
    isempty(data) && return nothing
    return JSON3.read(data[1][:grading_json], GradingResult)
end

function fetch_recommendation_result(db, review_id, citation_id)
    rows = DBInterface.execute(db, "SELECT recommendation_json FROM recommendations WHERE review_id=? AND citation_id=?", (review_id, citation_id))
    data = collect(rows)
    isempty(data) && return nothing
    return JSON3.read(data[1][:recommendation_json], RecommendationResult)
end

function upsert_grading_and_recommendation!(db, review_id, citation_id, grading, rec)
    insert_grading_result!(db, review_id, citation_id, grading)
    insert_recommendation_result!(db, review_id, citation_id, rec)
end

end