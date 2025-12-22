from src.loaders.gendo_loader import load_gendo
from src.exporters.atendimentos_raw_exporter import export_atendimentos_raw
from src.config import GENDO_CSV_PATH

def main():
    gendo_df = load_gendo(GENDO_CSV_PATH)
    export_atendimentos_raw(gendo_df)
    print("✅ Atendimentos RAW atualizado com sucesso")

if __name__ == "__main__":
    main()
