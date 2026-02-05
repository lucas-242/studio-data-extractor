-- Trigger to copy default commissions when a new professional is added
CREATE TRIGGER trg_new_professional_commissions
AFTER INSERT ON dw.dim_professionals
FOR EACH ROW
EXECUTE FUNCTION dw.fn_copy_default_commissions();