struct PrismaFlow
    total_records_retrieved::Int
    duplicates_removed::Int
    records_screened::Int
    records_excluded::Int
    exclusion_reasons::Dict{String,Int}
    studies_included::Int
end

struct ReviewPipelineWithPrisma
    pipeline::ReviewPipelineOutput
    prisma::PrismaFlow
end
