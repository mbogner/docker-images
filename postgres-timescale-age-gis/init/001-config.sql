ALTER SYSTEM SET search_path = ag_catalog, "$user", public;
ALTER SYSTEM SET session_preload_libraries = 'age';