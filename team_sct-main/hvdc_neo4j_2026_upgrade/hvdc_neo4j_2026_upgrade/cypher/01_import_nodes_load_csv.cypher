// Import OntologyNode rows. Copy neo4j-import/load-csv/*.csv into Neo4j import directory first.
// Compatible path: file:///nodes.csv

LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
MERGE (n:OntologyNode {id: row.id})
SET
  n.label = row.label,
  n.node_type = row.node_type,
  n.status = row.status,
  n.risk_level = row.risk_level,
  n.risk_reason = row.risk_reason,
  n.evidence_json = row.evidence_json,
  n.evidence_text = row.evidence_text,
  n.evidence_count = CASE row.evidence_count WHEN '' THEN 0 ELSE toInteger(row.evidence_count) END,
  n.business_rule = row.business_rule,
  n.last_updated = CASE row.last_updated WHEN '' THEN null ELSE datetime(row.last_updated) END,
  n.next_action = row.next_action,
  n.ai_confidence = CASE row.ai_confidence WHEN '' THEN null ELSE toFloat(row.ai_confidence) END,
  n.ai_ready = toBoolean(row.ai_ready),
  n.source = row.source,
  n.community = row.community,
  n.degree = CASE row.degree WHEN '' THEN null ELSE toInteger(row.degree) END,
  n.bridges = CASE row.bridges WHEN '' THEN null ELSE toInteger(row.bridges) END,
  n.governance_owner = row.governance_owner,
  n.graph_id = row.graph_id,
  n.schema_version = row.schema_version,
  n.needs_human_gate = toBoolean(row.needs_human_gate),
  n.zero_candidate = toBoolean(row.zero_candidate),
  n.pii_masked = toBoolean(row.pii_masked),
  n.text_for_embedding = row.text_for_embedding,
  n.labels_manifest = row.labels;
