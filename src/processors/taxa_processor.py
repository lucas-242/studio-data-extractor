def calcular_taxa(row):
    if row["taxa_valor"]:
        return row["taxa_valor"]
    if row["taxa_percentual"]:
        return row["total_pago"] * row["taxa_percentual"] / 100
    raise ValueError(f"Venda {row['venda_id']} sem taxa definida")
