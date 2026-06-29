# HVDC Neo4j 2026 Upgrade Pack

## 판정

현재 SCT AI-ready ontology graph를 Neo4j 2026 property graph + evidence locker + risk gate 구조로 변환했습니다.

## 입력 기준

- Input graph: `hvdc-sct-ai-ready-graph`
- Input schema: `2.1`
- Nodes: `191`
- Relationships: `286`
- Evidence rows: `1908`
- Risk gates: `35`

## 권장 실행: Docker + LOAD CSV

```bash
cd hvdc_neo4j_2026_upgrade/docker
docker compose up -d
```

Neo4j Browser: `http://localhost:7474`  
Bolt: `bolt://localhost:7687`  
User/pass: `neo4j/password12345`

컨테이너가 올라온 뒤 Docker 내부 `cypher-shell`로 실행:

```bash
cd ..
./scripts/docker_cypher_load_csv.sh
```

호스트에 `cypher-shell`이 설치되어 있으면 `./scripts/cypher_shell_load_csv.sh`도 사용 가능합니다.

## 빠른 수동 실행 순서

1. `neo4j-import/load-csv/*.csv`를 Neo4j import directory에 배치
2. `cypher/00_constraints.cypher`
3. `cypher/01_import_nodes_load_csv.cypher`
4. `cypher/02_add_static_labels.cypher`
5. `cypher/03_import_relationships_generic_compatible.cypher`
6. `cypher/04_import_edge_assertions_evidence_risks.cypher`
7. `cypher/05_vector_and_hybrid_search_2026.cypher`
8. `cypher/06_validation_queries.cypher`

## 관계 타입 선택

- 안정형: `03_import_relationships_generic_compatible.cypher` → 모든 관계를 `:GRAPH_RELATION`으로 생성하고 원래 타입은 property로 보관
- 2026/Cypher 25형: `03b_import_relationships_typed_cypher25.cypher` → `:REFERENCES`, `:PERFORMS_ROLE` 등 typed relationship 생성
- 대량/초기 DB: `neo4j-import/admin-import/*.csv` + `scripts/admin_import_full.sh`

## Benchmark

```bash
cd benchmark
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
NEO4J_PASSWORD=password12345 python run_benchmark.py
```

## 산출물 핵심

- Evidence는 문자열 property가 아니라 `(:Evidence)` 노드로 분리했습니다.
- Edge evidence는 `(:EdgeAssertion)` 노드로 우회 모델링했습니다.
- AMBER/INFERRED/critical domain node는 `(:RiskGate)`에 연결했습니다.
- Vector index는 embedding pipeline 승인 후 활성화하는 구조입니다.

## 운영 주의

본 패키지는 dry-run import/benchmark 패키지입니다. live operational truth 또는 ERP/WMS/ATLP write-back은 별도 승인 Action 없이는 금지합니다.
