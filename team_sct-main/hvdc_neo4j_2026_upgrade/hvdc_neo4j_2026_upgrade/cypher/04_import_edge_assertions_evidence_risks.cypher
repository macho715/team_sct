// Evidence locker + risk ledger import.
// EdgeAssertion nodes make relationship-level evidence traversable because Neo4j relationships cannot own outgoing relationships.

LOAD CSV WITH HEADERS FROM 'file:///edge_assertions.csv' AS row
MATCH (a:OntologyNode {id: row.from_id})
MATCH (b:OntologyNode {id: row.to_id})
MERGE (ea:EdgeAssertion {edge_id: row.edge_id})
SET
  ea.edge_type_norm = row.edge_type_norm,
  ea.edge_type = row.edge_type,
  ea.status = row.status,
  ea.risk_level = row.risk_level,
  ea.confidence = row.confidence,
  ea.evidence_text = row.evidence_text,
  ea.business_rule = row.business_rule,
  ea.last_updated = CASE row.last_updated WHEN '' THEN null ELSE datetime(row.last_updated) END,
  ea.next_action = row.next_action,
  ea.risk_reason = row.risk_reason,
  ea.needs_review = toBoolean(row.needs_review),
  ea.text_for_embedding = row.text_for_embedding
MERGE (a)-[:ASSERTION_FROM]->(ea)
MERGE (ea)-[:ASSERTION_TO]->(b);

LOAD CSV WITH HEADERS FROM 'file:///evidence.csv' AS row
MERGE (ev:Evidence {evidence_id: row.evidence_id})
SET
  ev.owner_type = row.owner_type,
  ev.owner_id = row.owner_id,
  ev.evidence_index = toInteger(row.evidence_index),
  ev.evidence_type = row.evidence_type,
  ev.evidence_value = row.evidence_value,
  ev.evidence_raw = row.evidence_raw,
  ev.review_status = row.review_status,
  ev.source_hash = row.source_hash,
  ev.hash_status = row.hash_status,
  ev.created_at = datetime(row.created_at);

LOAD CSV WITH HEADERS FROM 'file:///evidence.csv' AS row
WITH row WHERE row.owner_type = 'NODE'
MATCH (n:OntologyNode {id: row.owner_id})
MATCH (ev:Evidence {evidence_id: row.evidence_id})
MERGE (n)-[:CITES_EVIDENCE]->(ev);

LOAD CSV WITH HEADERS FROM 'file:///evidence.csv' AS row
WITH row WHERE row.owner_type = 'EDGE_ASSERTION'
MATCH (ea:EdgeAssertion {edge_id: row.owner_id})
MATCH (ev:Evidence {evidence_id: row.evidence_id})
MERGE (ea)-[:CITES_EVIDENCE]->(ev);

LOAD CSV WITH HEADERS FROM 'file:///risk_gates.csv' AS row
MERGE (rg:RiskGate {risk_id: row.risk_id})
SET
  rg.owner_type = row.owner_type,
  rg.owner_id = row.owner_id,
  rg.risk_level = row.risk_level,
  rg.status = row.status,
  rg.reason = row.reason,
  rg.required_action = row.required_action,
  rg.gate_policy = row.gate_policy,
  rg.created_at = datetime(row.created_at);

LOAD CSV WITH HEADERS FROM 'file:///risk_gates.csv' AS row
WITH row WHERE row.owner_type = 'NODE'
MATCH (n:OntologyNode {id: row.owner_id})
MATCH (rg:RiskGate {risk_id: row.risk_id})
MERGE (n)-[:BLOCKED_BY]->(rg);

LOAD CSV WITH HEADERS FROM 'file:///risk_gates.csv' AS row
WITH row WHERE row.owner_type = 'EDGE_ASSERTION'
MATCH (ea:EdgeAssertion {edge_id: row.owner_id})
MATCH (rg:RiskGate {risk_id: row.risk_id})
MERGE (ea)-[:BLOCKED_BY]->(rg);
