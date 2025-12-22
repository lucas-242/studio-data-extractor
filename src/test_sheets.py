from src.loaders.sheets_loader import load_transacoes_cartao

df = load_transacoes_cartao()
print(df.dtypes)
print(df.head())
