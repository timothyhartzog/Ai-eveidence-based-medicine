Implement Phase 1: bootstrap the Julia project scaffold.

Create:
- Project.toml
- src/ layout
- config/ layout
- test/ layout
- docs/ layout
- minimal Genie app
- one POST /reviews endpoint stub
- startup instructions in README.md

Constraints:
- Use modular folders for:
  - agents
  - llm
  - pubmed
  - pipelines
  - db
  - api
  - documents
  - utils
- Keep code minimal but runnable
- Prefer working code over explanation

Done when:
- project instantiates
- Genie starts
- POST /reviews returns a JSON stub response
- tests run successfully

After coding:
- summarize files created
- show exact commands to run
