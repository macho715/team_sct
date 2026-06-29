// Preferred relationship import for Neo4j 2026/Cypher 25: dynamic relationship type.
// If this fails in your environment, run 03_import_relationships_generic_compatible.cypher instead.

LOAD CSV WITH HEADERS FROM 'file:///relationships.csv' AS row
MATCH (a:OntologyNode {id: row.from_id})
MATCH (b:OntologyNode {id: row.to_id})
CREATE (a)-[r:$(row.edge_type_norm)]->(b)
SET
  r.id = row.id,
  r.edge_type = row.edge_type,
  r.edge_type_norm = row.edge_type_norm,
  r.status = row.status,
  r.risk_level = row.risk_level,
  r.confidence = row.confidence,
  r.evidence_json = row.evidence_json,
  r.evidence_text = row.evidence_text,
  r.business_rule = row.business_rule,
  r.last_updated = CASE row.last_updated WHEN '' THEN null ELSE datetime(row.last_updated) END,
  r.next_action = row.next_action,
  r.risk_reason = row.risk_reason,
  r.from_node_type = row.from_node_type,
  r.to_node_type = row.to_node_type,
  r.ai_ready = toBoolean(row.ai_ready),
  r.needs_review = toBoolean(row.needs_review),
  r.text_for_embedding = row.text_for_embedding;
