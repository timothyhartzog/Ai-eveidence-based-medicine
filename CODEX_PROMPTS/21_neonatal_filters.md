Implement neonatal-specific search filters.

Add:
- neonatal MeSH candidate expansions
- newborn / infant / preterm / gestational age keyword blocks
- NICU terminology support
- term vs preterm subgroup filters
- direct neonatal-only query variants

Requirements:
- integrate with the PubMed query builder
- keep filters configurable
- document exclusions to reduce adult drift
- add tests for common neonatal topics

Done when:
- sample neonatal topics generate neonatal-specific PubMed queries
- filters clearly separate neonatal from broader pediatric searches
- tests cover preterm, newborn, and NICU-focused examples
