-- Insert default commissions for new professional
CREATE OR REPLACE FUNCTION dw.fn_copy_default_commissions()
RETURNS TRIGGER AS $$
BEGIN
    -- Inserir para o novo profissional (NEW.professional_id) 
    -- a comissão padrão de todos os serviços ativos
    INSERT INTO dw.dim_commission_rules (professional_id, service_id, commission_percentage)
    SELECT 
        NEW.professional_id, 
        service_id, 
        default_commission_percentage
    FROM dw.dim_services
    WHERE is_active = TRUE 
      AND default_commission_percentage > 0
    ON CONFLICT (professional_id, service_id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;