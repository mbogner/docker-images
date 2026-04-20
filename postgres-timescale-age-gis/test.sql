--- run this in psql cli

CREATE DATABASE test;
\c test

SHOW search_path;
SHOW session_preload_libraries;

SELECT * FROM pg_extension;
SELECT ag_catalog.create_graph('net_graph');
SELECT * FROM cypher('net_graph', $$ RETURN 1 $$) AS (v agtype);