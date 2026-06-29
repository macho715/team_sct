// HVDC validation / QA queries.

// 1) Import counts
MATCH (n:OntologyNode) RETURN count(n) AS ontology_nodes;
MATCH ()-[r:GRAPH_RELATION]->() RETURN count(r) AS generic_relationships;
MATCH (ea:EdgeAssertion) RETURN count(ea) AS edge_assertions;
MATCH (ev:Evidence) RETURN count(ev) AS evidence_nodes;
MATCH (rg:RiskGate) RETURN count(rg) AS risk_gates;

// 2) AMBER / ZERO queue
MATCH (n:OntologyNode)-[:BLOCKED_BY]->(r:RiskGate)
RETURN r.risk_level AS risk_level, n.node_type AS node_type, n.id AS id, n.label AS label, r.reason AS reason, r.required_action AS action
ORDER BY risk_level DESC, node_type, label;

// 3) Missing evidence or missing source hash
MATCH (n:OntologyNode)
WHERE NOT (n)-[:CITES_EVIDENCE]->(:Evidence)
RETURN n.id, n.label, n.node_type, n.status
ORDER BY n.status DESC, n.node_type;

MATCH (n:OntologyNode)-[:CITES_EVIDENCE]->(ev:Evidence)
WHERE ev.hash_status = 'MISSING_SOURCE_HASH'
RETURN n.node_type, n.label, count(ev) AS missing_hash_evidence
ORDER BY missing_hash_evidence DESC;

// 4) Inferred edge review queue
MATCH (a:OntologyNode)-[:ASSERTION_FROM]->(ea:EdgeAssertion)-[:ASSERTION_TO]->(b:OntologyNode)
WHERE ea.needs_review = true OR ea.confidence = 'INFERRED'
RETURN ea.edge_id, ea.edge_type_norm, a.label AS from_label, b.label AS to_label, ea.status, ea.confidence, ea.next_action
ORDER BY ea.status DESC, ea.edge_id;

// 5) Cost/customs/marine critical nodes with unresolved gate
MATCH (n:DomainCritical)-[:BLOCKED_BY]->(r:RiskGate)
RETURN n.node_type, n.label, r.risk_level, r.reason, r.required_action
ORDER BY r.risk_level DESC, n.node_type;
