#!/usr/bin/env bash
set -euo pipefail
CONTAINER=${NEO4J_CONTAINER:-hvdc-neo4j-2026}
USER=${NEO4J_USER:-neo4j}
PASS=${NEO4J_PASSWORD:-password12345}
DB=${NEO4J_DATABASE:-neo4j}

for f in \
  cypher/00_constraints.cypher \
  cypher/01_import_nodes_load_csv.cypher \
  cypher/02_add_static_labels.cypher \
  cypher/03_import_relationships_generic_compatible.cypher \
  cypher/04_import_edge_assertions_evidence_risks.cypher \
  cypher/05_vector_and_hybrid_search_2026.cypher \
  cypher/06_validation_queries.cypher; do
  echo "Running $f in $CONTAINER"
  docker exec -i "$CONTAINER" cypher-shell -u "$USER" -p "$PASS" -d "$DB" < "$f"
done
