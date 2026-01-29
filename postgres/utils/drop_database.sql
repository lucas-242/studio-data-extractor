SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'studio'
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS studio;
