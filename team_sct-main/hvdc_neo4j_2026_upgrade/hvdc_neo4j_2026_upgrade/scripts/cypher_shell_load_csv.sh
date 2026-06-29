#!/usr/bin/env bash
set -euo pipefail
# Load CSV into a running Neo4j database.
# Copy neo4j-import/load-csv/*.csv to the Neo4j import directory or mount it as /import.

URI=${NEO4J_URI:-bolt://localhost:7687}
USER=${NEO4J_USER:-neo4j}
PASS=${NEO4J_PASSWORD:-password12345}
DB=${NEO4J_DATABASE:-neo4j}

for f in   cypher/00_constraints.cypher   cypher/01_import_nodes_load_csv.cypher   cypher/02_add_static_labels.cypher   cypher/03_import_relationships_generic_compatible.cypher   cypher/04_import_edge_assertions_evidence_risks.cypher   cypher/05_vector_and_hybrid_search_2026.cypher   cypher/06_validation_queries.cypher; do
  echo "Running $f"
  cypher-shell -a "$URI" -u "$USER" -p "$PASS" -d "$DB" -f "$f"
done
