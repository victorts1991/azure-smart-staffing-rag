import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

# Inicializa o Faker para gerar nomes e endereços brasileiros

fake = Faker('pt_BR')

def generate_vigilante_data(n_records=400):
    vigilantes = []

    # Pool de certificações reais do setor de segurança armada
    certificacoes_pool = [
        "Vigilância Patrimonial", 
        "Transporte de Valores", 
        "Escolta Armada", 
        "Segurança Pessoal (VSPP)", 
        "Grandes Eventos", 
        "Monitoramento de CFTV"
    ]

    escalas_pool = ["12x36 Dia", "12x36 Noite", "5x2 Comercial"]

    for i in range(n_records):
        # Gera data de reciclagem (algumas vencidas para testar os filtros da IA)
        data_reciclagem = fake.date_between(start_date='-1y', end_date='+2y')
        
        # Sorteia de 1 a 3 cursos para cada vigilante
        cursos = random.sample(certificacoes_pool, k=random.randint(1, 3))
        
        vigilante = {
            "id_funcional": f"VIG-{10000 + i}",
            "nome_completo": fake.name(),
            "cpf": fake.cpf(),
            "vencimento_reciclagem": data_reciclagem.strftime('%Y-%m-%d'),
            "certificacoes": ", ".join(cursos),
            "nota_performance": round(random.uniform(6.5, 10.0), 1),
            "cep_base": fake.postcode(),
            "escala_atual": random.choice(escalas_pool),
            "ultimo_posto": fake.company() + " - Unidade " + str(random.randint(1, 10))
        }
        vigilantes.append(vigilante)

    return pd.DataFrame(vigilantes)


def create_sample_scale(df_vigilantes):
    # Seleciona os primeiros vigilantes para simular quem precisa de cobertura (ex: João de Deus)
    escala = df_vigilantes.head(10).copy()
    escala['posto_atual'] = "Posto Bancário Centro - Agência " + fake.city()
    escala['data_inicio_ferias'] = (datetime.now() + timedelta(days=2)).strftime('%Y-%m-%d')
    return escala[['id_funcional', 'nome_completo', 'posto_atual', 'data_inicio_ferias']]

if __name__ == "__main__":
    print("⏳ Iniciando geração da massa de dados sintéticos...")

    # 1. Gerar base total (os substitutos)
    df_total = generate_vigilante_data(400)
    df_total.to_csv('base_vigilantes_ativos.csv', index=False, encoding='utf-8-sig')

    # 2. Gerar escala de teste (os que sairão de férias)
    df_escala = create_sample_scale(df_total)
    df_escala.to_csv('escala_atual.csv', index=False, encoding='utf-8-sig')

    print(f"✅ Sucesso!")
    print(f"📂 Arquivo 'base_vigilantes_ativos.csv' criado com {len(df_total)} registros.")
    print(f"📂 Arquivo 'escala_atual.csv' criado para testes de substituição.")
