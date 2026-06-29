#!/usr/bin/env bash
set -euo pipefail
# Full offline import. Run when database does not exist yet.
# Adjust NEO4J_HOME and DB_NAME as needed.
NEO4J_HOME=${NEO4J_HOME:-/var/lib/neo4j}
DB_NAME=${DB_NAME:-hvdc}
IMPORT_DIR=${IMPORT_DIR:-$(pwd)/neo4j-import/admin-import}

neo4j-admin database import full "$DB_NAME"   --overwrite-destination=true   --nodes="$IMPORT_DIR/nodes.csv"   --relationships="$IMPORT_DIR/relationships.csv"

echo "Import completed for database: $DB_NAME"
