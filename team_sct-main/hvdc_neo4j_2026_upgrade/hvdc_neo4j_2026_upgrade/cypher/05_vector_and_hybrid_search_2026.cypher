// Neo4j 2026/Cypher 25 vector + hybrid search layer.
// Precondition: populate n.embedding as a 1536-dim vector/list using an approved embedding pipeline.
// The index stores filterable properties for low-latency in-index filtering.

CREATE VECTOR INDEX ontology_embedding_v1 IF NOT EXISTS
FOR (n:OntologyNode)
ON n.embedding
WITH [n.node_type, n.status, n.governance_owner, n.zero_candidate]
OPTIONS { indexConfig: {
  `vector.dimensions`: 1536,
  `vector.similarity_function`: 'cosine',
  `vector.quantization.enabled`: true
}};

// Example: Cypher 25 SEARCH with in-index filtering.
// Parameter required: $query_embedding = 1536-dim list/vector.
/*
MATCH (n:OntologyNode)
  SEARCH n IN (
    VECTOR INDEX ontology_embedding_v1
    FOR $query_embedding
    WHERE n.status <> 'ZERO' AND n.zero_candidate = false
    LIMIT 10
  ) SCORE AS score
RETURN n.id, n.label, n.node_type, n.status, score
ORDER BY score DESC;
*/

// Hybrid retrieval pattern: full-text candidates + graph expansion + risk gate filter.
// Parameter required: $q.
/*
CALL db.index.fulltext.queryNodes('ontology_text_fulltext', $q, {limit: 20})
YIELD node, score
MATCH p = (node)-[*0..2]-(ctx)
WHERE NOT (ctx)-[:BLOCKED_BY]->(:RiskGate {risk_level: 'ZERO'})
RETURN node.id AS seed_id, node.label AS seed_label, score, collect(DISTINCT ctx.label)[0..20] AS context
ORDER BY score DESC
LIMIT 10;
*/
