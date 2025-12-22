import pandas as pd
from src.loaders.sheets_loader import read_sheet, append_rows

ABA_ATENDIMENTOS_RAW = "Atendimentos RAW"


def load_gendo_csv(csv_path: str):
    # 1. Lê o CSV do Gendo
    df = pd.read_csv(
        csv_path,
        sep=",",
        encoding="utf-8"
    )

    # 2. Converte Total para número (seguro)
    df["Total"] = pd.to_numeric(df["Total"], errors="coerce")

    # 3. Remove linhas sem valor (opcional, mas recomendado)
    df = df[df["Total"].notna()]

    # 4. Gera ID externo
    df["ID externo"] = (
        df["Cód. Comanda"].astype(str)
        + "|"
        + df["Serviço"].astype(str)
        + "|"
        + df["Total"].astype(str)
    )

    # 5. Lê dados existentes no Sheets
    existing = read_sheet(ABA_ATENDIMENTOS_RAW)

    if not existing.empty:
        existing_ids = set(existing["ID externo"].astype(str))
        df = df[~df["ID externo"].isin(existing_ids)]

    if df.empty:
        print("Nenhum atendimento novo para importar.")
        return

    # 6. Substitui NaN restantes por vazio (CRÍTICO)
    df = df.fillna("")

    # 7. Monta linhas exatamente no formato da aba
    rows = []
    for _, row in df.iterrows():
        rows.append([
            str(row["Data"]),
            str(row["Colaborador"]),
            str(row["Serviço"]),
            float(row["Total"]),
            str(row["Forma Pagto"]),
            "Gendo",
            str(row["ID externo"]),
        ])

    # 8. Append no Sheets
    append_rows(ABA_ATENDIMENTOS_RAW, rows)

    print(f"{len(rows)} atendimentos importados com sucesso.")
