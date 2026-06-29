#!/usr/bin/env python3
"""
Run repeatable micro-benchmarks against the imported HVDC Neo4j graph.
Environment:
  NEO4J_URI=bolt://localhost:7687
  NEO4J_USER=neo4j
  NEO4J_PASSWORD=password12345
  NEO4J_DATABASE=neo4j
"""
import os
import statistics
import time
from dataclasses import dataclass
from typing import Dict, Any, List

from neo4j import GraphDatabase

URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
USER = os.getenv("NEO4J_USER", "neo4j")
PASSWORD = os.getenv("NEO4J_PASSWORD", "password12345")
DATABASE = os.getenv("NEO4J_DATABASE", "neo4j")
RUNS = int(os.getenv("BENCH_RUNS", "30"))
WARMUPS = int(os.getenv("BENCH_WARMUPS", "5"))

QUERIES: Dict[str, str] = {
    "B01_exact_lookup": """
        MATCH (n:OntologyNode {id: $id})
        RETURN n.id AS id, n.label AS label, n.status AS status
    """,
    "B02_risk_queue": """
        MATCH (n:OntologyNode)-[:BLOCKED_BY]->(r:RiskGate)
        RETURN r.risk_level AS level, count(*) AS cnt
        ORDER BY level
    """,
    "B03_evidence_traversal": """
        MATCH p=(n:OntologyNode)-[*1..3]-(ev:Evidence)
        WHERE n.node_type IN ['Invoice','InvoiceLine','CostPolicy','CostGuardResult']
        RETURN count(DISTINCT ev) AS evidence_count, count(DISTINCT n) AS seed_nodes
    """,
    "B04_inferred_edges": """
        MATCH (a:OntologyNode)-[:ASSERTION_FROM]->(ea:EdgeAssertion)-[:ASSERTION_TO]->(b:OntologyNode)
        WHERE ea.needs_review = true OR ea.confidence = 'INFERRED'
        RETURN count(ea) AS review_edges
    """,
    "B05_fulltext": """
        CALL db.index.fulltext.queryNodes('ontology_text_fulltext', $q, {limit: 10})
        YIELD node, score
        RETURN node.id AS id, node.label AS label, score
        ORDER BY score DESC
    """,
    "B06_fulltext_expand": """
        CALL db.index.fulltext.queryNodes('ontology_text_fulltext', $q, {limit: 5})
        YIELD node, score
        MATCH p=(node)-[*0..2]-(ctx:OntologyNode)
        RETURN node.id AS seed, score, count(DISTINCT ctx) AS ctx_count
        ORDER BY score DESC
    """,
}

PARAMS: Dict[str, Dict[str, Any]] = {
    "B01_exact_lookup": {"id": "concept_invoice_audit"},
    "B05_fulltext": {"q": "invoice tariff free-time BOE evidence"},
    "B06_fulltext_expand": {"q": "invoice tariff free-time BOE evidence"},
}

@dataclass
class Result:
    query: str
    runs: int
    p50_ms: float
    p95_ms: float
    min_ms: float
    max_ms: float
    rows_last: int


def percentile(values: List[float], pct: float) -> float:
    if not values:
        return 0.0
    values = sorted(values)
    k = (len(values) - 1) * pct
    f = int(k)
    c = min(f + 1, len(values) - 1)
    if f == c:
        return values[int(k)]
    return values[f] * (c - k) + values[c] * (k - f)


def run_one(session, name: str, cypher: str) -> Result:
    params = PARAMS.get(name, {})
    for _ in range(WARMUPS):
        list(session.run(cypher, params))
    durations = []
    rows_last = 0
    for _ in range(RUNS):
        t0 = time.perf_counter()
        rows = list(session.run(cypher, params))
        t1 = time.perf_counter()
        durations.append((t1 - t0) * 1000)
        rows_last = len(rows)
    return Result(
        query=name,
        runs=RUNS,
        p50_ms=statistics.median(durations),
        p95_ms=percentile(durations, 0.95),
        min_ms=min(durations),
        max_ms=max(durations),
        rows_last=rows_last,
    )


def main() -> None:
    driver = GraphDatabase.driver(URI, auth=(USER, PASSWORD))
    try:
        with driver.session(database=DATABASE) as session:
            results = [run_one(session, name, q) for name, q in QUERIES.items()]
        print("| Query | Runs | p50 ms | p95 ms | Min ms | Max ms | Rows |")
        print("|---|---:|---:|---:|---:|---:|---:|")
        for r in results:
            print(f"| {r.query} | {r.runs} | {r.p50_ms:.2f} | {r.p95_ms:.2f} | {r.min_ms:.2f} | {r.max_ms:.2f} | {r.rows_last} |")
    finally:
        driver.close()

if __name__ == "__main__":
    main()
