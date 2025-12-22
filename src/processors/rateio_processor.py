def ratear_taxa(gendo_df, transacoes_df):
    resultado = []

    for venda_id, grupo in gendo_df.groupby("venda_id"):
        transacao = transacoes_df[transacoes_df["venda_id"] == venda_id]

        if transacao.empty:
            raise ValueError(f"Venda {venda_id} não encontrada")

        taxa_total = transacao.iloc[0]["taxa_calculada"]
        total_servicos = grupo["valor_servico"].sum()

        for _, row in grupo.iterrows():
            proporcao = row["valor_servico"] / total_servicos
            taxa_rateada = taxa_total * proporcao

            resultado.append({
                **row,
                "taxa_rateada": round(taxa_rateada, 2),
                "valor_liquido": round(row["valor_servico"] - taxa_rateada, 2)
            })

    return resultado
