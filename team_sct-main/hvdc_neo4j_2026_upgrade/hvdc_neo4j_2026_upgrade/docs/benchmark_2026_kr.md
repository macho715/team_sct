# HVDC Neo4j 2026 Upgrade Pack — Benchmark & Trend Report

Generated: 2026-06-14T17:34:09+00:00

## 1. Input graph baseline

| Metric | Value |
|---|---:|
| Nodes | 191 |
| Relationships | 286 |
| Evidence rows generated | 1908 |
| Risk gates generated | 35 |
| Node PASS | 164 |
| Node AMBER | 27 |
| Edge PASS | 278 |
| Edge AMBER | 8 |

Top node types: {"Document": 62, "MarineOperation": 10, "Person": 9, "ActorRole": 9, "OffshoreStagingNode": 8, "RoutingPattern": 8, "WarehouseTask": 6, "Standard": 6, "CommunicationEvent": 6, "CustomsEntry": 5}

Top relationship types: {"REFERENCES": 171, "PERFORMS_ROLE": 39, "IMPLEMENTS_MODEL": 17, "SHARES_DATA_WITH": 15, "GOVERNS": 14, "CONCEPTUALLY_RELATED_TO": 11, "CITES_EVIDENCE": 8, "SUPPORTS": 3, "SIMILAR_TO": 2, "SUPPORTS_PROCESS": 1}

## 2. 2026 Neo4j target baseline

Recommended default: **Neo4j 2026.05.0** for new pilot deployment.
Conservative fallback: **Neo4j 5.26 LTS** where long-term support and change control are more important than latest Cypher 25 vector features.

Why 2026.05.0:
- Neo4j public support page lists 2026.05.0 released on 2026-05-28 and compatible with 6.x / 5.x / 4.4-limited drivers.
- Neo4j operations manual says 2026.02 sets Cypher 25 as the default language in distributed `neo4j.conf`.
- Neo4j 2026.02 made vector search with filters generally available, enabling in-index filtering by status/type/tenant-like metadata.
- GDS 2026.05.0 is listed as compatible with Neo4j 2026.05.

Key sources checked:
- Neo4j supported versions: https://neo4j.com/developer/kb/neo4j-supported-versions/
- Neo4j operations 2025-2026 changes: https://neo4j.com/docs/operations-manual/current/changes-2025-2026/
- Neo4j vector indexes: https://neo4j.com/docs/cypher-manual/current/indexes/semantic-indexes/vector-indexes/
- Neo4j SEARCH clause: https://neo4j.com/docs/cypher-manual/current/clauses/search/
- Neo4j GDS release notes: https://neo4j.com/release-notes/gds/
- Neo4j Docker documentation: https://neo4j.com/docs/operations-manual/current/docker/introduction/

## 3. Benchmark posture for HVDC graph

This graph is small enough that raw database throughput should not be the main KPI. The useful benchmark is **retrieval quality + evidence traceability + human-gate leakage**.

Recommended benchmark matrix:

| Mode | What to test | KPI |
|---|---|---|
| JSON/HTML baseline | Existing local search/filter | Query time, manual traceability |
| Neo4j property graph | Node lookup, relationship expansion, AMBER queue | p50/p95 ms, path explainability |
| Neo4j full-text | `ontology_text_fulltext` retrieval | Top-k relevance, missed evidence |
| Neo4j GraphRAG hybrid | full-text/vector + graph expansion | grounded answer precision, ZERO leakage |
| GDS optional | PageRank/WCC/community detection | graph QA, bridge nodes, risk propagation |

## 4. Files generated

- `neo4j-import/load-csv/nodes.csv`
- `neo4j-import/load-csv/relationships.csv`
- `neo4j-import/load-csv/evidence.csv`
- `neo4j-import/load-csv/edge_assertions.csv`
- `neo4j-import/load-csv/risk_gates.csv`
- `neo4j-import/admin-import/nodes.csv`
- `neo4j-import/admin-import/relationships.csv`
- `cypher/*.cypher`
- `benchmark/run_benchmark.py`
- `docker/docker-compose.yml`

## 5. ZERO gate note

This upgrade does **not** convert AI-ready graph status into live operational truth. Any HS/customs/cost/OOG/stability/approval mutation remains blocked until source-system evidence and human approval are attached.
