// HVDC Neo4j 2026 upgrade — constraints and lookup indexes
// Run before LOAD CSV import.

CREATE CONSTRAINT ontology_node_id_unique IF NOT EXISTS
FOR (n:OntologyNode)
REQUIRE n.id IS UNIQUE;

CREATE CONSTRAINT edge_assertion_id_unique IF NOT EXISTS
FOR (e:EdgeAssertion)
REQUIRE e.edge_id IS UNIQUE;

CREATE CONSTRAINT evidence_id_unique IF NOT EXISTS
FOR (ev:Evidence)
REQUIRE ev.evidence_id IS UNIQUE;

CREATE CONSTRAINT risk_gate_id_unique IF NOT EXISTS
FOR (r:RiskGate)
REQUIRE r.risk_id IS UNIQUE;

CREATE RANGE INDEX ontology_node_status IF NOT EXISTS
FOR (n:OntologyNode)
ON (n.status);

CREATE RANGE INDEX ontology_node_type IF NOT EXISTS
FOR (n:OntologyNode)
ON (n.node_type);

CREATE RANGE INDEX ontology_node_human_gate IF NOT EXISTS
FOR (n:OntologyNode)
ON (n.needs_human_gate);

CREATE RANGE INDEX edge_assertion_status IF NOT EXISTS
FOR (e:EdgeAssertion)
ON (e.status);

CREATE RANGE INDEX risk_gate_level IF NOT EXISTS
FOR (r:RiskGate)
ON (r.risk_level);

CREATE FULLTEXT INDEX ontology_text_fulltext IF NOT EXISTS
FOR (n:OntologyNode)
ON EACH [n.label, n.node_type, n.status, n.business_rule, n.next_action, n.risk_reason, n.evidence_text, n.text_for_embedding];

CREATE FULLTEXT INDEX evidence_text_fulltext IF NOT EXISTS
FOR (ev:Evidence)
ON EACH [ev.evidence_raw, ev.evidence_type, ev.evidence_value, ev.review_status];
