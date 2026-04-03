module EvidenceTables

using DataFrames
using CSV
using JSON3
using ..GradingEngine

export build_evidence_table, write_evidence_table_csv, write_evidence_table_json

function build_evidence_table(rows)
    df = DataFrame(rows)
    return df
end

function write_evidence_table_csv(path, df)
    CSV.write(path, df)
end

function write_evidence_table_json(path, df)
    open(path, "w") do io
        write(io, JSON3.write(df))
    end
end

end