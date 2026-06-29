// Benchmark suite for the HVDC ontology graph. Use after import.

:param q => 'invoice tariff free-time BOE evidence';

// B01: exact node lookup
MATCH (n:OntologyNode {id: 'concept_invoice_audit'})
RETURN n.id, n.label, n.status;

// B02: AMBER/ZERO queue
MATCH (n:OntologyNode)-[:BLOCKED_BY]->(r:RiskGate)
RETURN r.risk_level, count(*) AS cnt
ORDER BY r.risk_level;

// B03: evidence traversal around invoice/cost nodes
MATCH p=(n:OntologyNode)-[*1..3]-(ev:Evidence)
WHERE n.node_type IN ['Invoice','InvoiceLine','CostPolicy','CostGuardResult']
RETURN count(DISTINCT ev) AS evidence_count, count(DISTINCT n) AS seed_nodes;

// B04: marine missing/pending evidence
MATCH (n:MarineOperation)-[:CITES_EVIDENCE]->(ev:Evidence)
WHERE ev.review_status <> 'approved_ai_ready'
RETURN n.id, n.label, collect(ev.evidence_raw)[0..5] AS pending_evidence;

// B05: full-text retrieval
CALL db.index.fulltext.queryNodes('ontology_text_fulltext', $q, {limit: 10})
YIELD node, score
RETURN node.id, node.label, node.node_type, node.status, score
ORDER BY score DESC;

// B06: graph expansion from retrieved seeds
CALL db.index.fulltext.queryNodes('ontology_text_fulltext', $q, {limit: 5})
YIELD node, score
MATCH p=(node)-[*0..2]-(ctx:OntologyNode)
RETURN node.id AS seed, score, count(DISTINCT ctx) AS ctx_count
ORDER BY score DESC;
