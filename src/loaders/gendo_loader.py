import re
import pandas as pd
from unidecode import unidecode
from src.services.sheets_service import read_sheet

def load_gendo_csv(csv_path: str) -> pd.DataFrame:
    """Loads and processes Gendo CSV."""
    df = pd.read_csv(
        csv_path,
        sep=",",
        encoding="utf-8"
    )

    if "Telefone" in df.columns:
        df["Telefone"] = (
            df["Telefone"]
            .astype(str)
            .str.replace(r"\.0$", "", regex=True)
        )
        df.loc[df["Telefone"].str.lower().isin(["nan", "none", "null"]), "Telefone"] = ""

    if "Cliente" in df.columns:
        df["Cliente"] = df["Cliente"].astype(str)

    df["Total"] = pd.to_numeric(df["Total"], errors="coerce")
    df = df[df["Total"].notna()]

    df["ID externo"] = (
        df["Cód. Comanda"].astype(str)
        + "|"
        + df["Serviço"].astype(str)
        + "|"
        + df["Total"].astype(str)
    )

    return df


def filter_new_atendimentos(df: pd.DataFrame) -> pd.DataFrame:
    """Filters only new appointments that do not exist in the sheet."""
    existing = read_sheet("Atendimentos RAW")
    
    if not existing.empty and "ID externo" in existing.columns:
        existing_ids = set(existing["ID externo"].astype(str))
        df = df[~df["ID externo"].isin(existing_ids)]
    
    return df


def format_for_export(df: pd.DataFrame) -> list[list]:
    """Formats DataFrame rows for export."""
    df = df.fillna("")

    df["Forma Pagto"] = df["Forma Pagto"].replace({
        "PIX (Externo)": "Pix",
        "*Credito Pacote": "Crédito Pacote"
    })
    
    rows = []
    for _, row in df.iterrows():
        cliente = normalize_text(str(row["Cliente"]))
        telefone = format_phone_number(str(row["Telefone"]))
        
        rows.append([
            str(row["Data"]),
            str(row["Colaborador"]),
            str(row["Serviço"]),
            cliente,
            telefone,
            str(row["Qts"]),
            str(row["Categoria"]),
            float(row["Total"]),
            str(row["Forma Pagto"]),
            "Gendo",
            str(row["ID externo"]),
        ])
    
    return rows

def normalize_text(text: str) -> str:
    """Normalize text by removing accents."""
    if not isinstance(text, str):
        return ""

    cleaned = text.strip()
    if "Ã" in cleaned or "Â" in cleaned:
        try:
            cleaned = cleaned.encode("latin1").decode("utf-8")
        except UnicodeError:
            pass

    return unidecode(cleaned).strip()


def format_phone_number(phone: str) -> str:
    """Format phone number to (XX) XXXXX-XXXX or (XX) XXXX-XXXX pattern."""
    if not isinstance(phone, str):
        return ""

    cleaned = phone.strip()
    if cleaned == "" or cleaned.lower() in {"nan", "none", "null"}:
        return ""
    if re.fullmatch(r"\d+\.0", cleaned):
        cleaned = cleaned.split(".", 1)[0]
    else:
        cleaned = re.sub(r"\.0$", "", cleaned)

    digits = re.sub(r"\D", "", cleaned)
    
    if len(digits) == 10: 
        return f"({digits[:2]}) {digits[2:6]}-{digits[6:]}"
    elif len(digits) == 11: 
        return f"({digits[:2]}) {digits[2:7]}-{digits[7:]}"
    return phone
