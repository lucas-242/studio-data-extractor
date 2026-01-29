CREATE OR REPLACE FUNCTION analytics.safe_utf8(input TEXT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN convert_from(convert_to(input, 'LATIN1'), 'UTF8');
EXCEPTION
  WHEN others THEN
    RETURN input;
END;
$$;
