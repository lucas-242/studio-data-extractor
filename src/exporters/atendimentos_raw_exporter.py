import gspread
from oauth2client.service_account import ServiceAccountCredentials
from src.config import (
    GOOGLE_CREDENTIALS_FILE,
    SPREADSHEET_NAME,
)

ABA_ATENDIMENTOS_RAW = "Atendimentos RAW"

HEADERS = [
    "Data Atendimento",
    "Prestadora RAW",
    "Serviço RAW",
    "Valor Bruto",
    "Forma Pagamento",
    "Origem Relatorio",
    "ID externo",
]

def export_atendimentos_raw(df):
    scope = [
        "https://spreadsheets.google.com/feeds",
        "https://www.googleapis.com/auth/drive"
    ]

    creds = ServiceAccountCredentials.from_json_keyfile_name(
        GOOGLE_CREDENTIALS_FILE, scope
    )

    client = gspread.authorize(creds)
    sheet = client.open(SPREADSHEET_NAME)

    try:
        worksheet = sheet.worksheet(ABA_ATENDIMENTOS_RAW)
    except gspread.WorksheetNotFound:
        worksheet = sheet.add_worksheet(
            title=ABA_ATENDIMENTOS_RAW,
            rows="1000",
            cols=str(len(HEADERS))
        )

    # Limpa tudo
    worksheet.clear()

    # Escreve cabeçalho
    worksheet.append_row(HEADERS)

    # Escreve dados
    rows = []
    for _, row in df.iterrows():
        rows.append([
            row["data"],
            row["profissional"],
            row["servico"],
            row["valor_servico"],
            row.get("forma_pagamento"),
            "Gendo",
            row["venda_id"],
        ])

    if rows:
        worksheet.append_rows(rows, value_input_option="USER_ENTERED")
