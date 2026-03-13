import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

# Inicializa o Faker para gerar nomes e endereços brasileiros
fake = Faker('pt_BR')

def mask_cpf(cpf):
    # Transforma 785.069.142-30 em 785.***.***-30
    parts = cpf.split('.')
    # Captura o sufixo após o último ponto e traço
    suffix = parts[2].split('-')[1]
    return f"{parts[0]}.***.***-{suffix}"

def generate_soft_skills():
    # Pool de habilidades baseadas em cenários reais de segurança
    skills_pool = [
        "Comunicação Assertiva", "Empatia", "Resolução de Conflitos", 
        "Perfil Analítico", "Trabalho sob Pressão", "Proatividade",
        "Discrição", "Liderança de Equipe", "Atenção Concentrada", 
        "Inteligência Emocional", "Pontualidade Extrema"
    ]
    # Retorna de 2 a 6 skills aleatórias
    return random.sample(skills_pool, k=random.randint(2, 6))

def generate_vigilante_data(n_records=400):
    vigilantes = []

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
        # MOVIDO PARA DENTRO DO LOOP: Cada iteração gera um CPF novo
        raw_cpf = fake.cpf()
        masked_cpf = mask_cpf(raw_cpf)

        data_reciclagem = fake.date_between(start_date='-1y', end_date='+2y')

        soft_skills = generate_soft_skills()

        # Criando um pequeno "histórico de feedback" (útil para o RAG justificar)
        feedbacks = [
            "Profissional muito elogiado pelo cliente.",
            "Possui postura exemplar e uniforme sempre impecável.",
            "Demonstra facilidade em lidar com público diverso.",
            "Focado e observador, antecipa riscos no perímetro.",
            "Excelente pontualidade e assiduidade."
        ]

        cursos = random.sample(certificacoes_pool, k=random.randint(1, 3))
        
        vigilante = {
            "id_funcional": f"VIG-{10000 + i}",
            "nome_completo": fake.name(),
            "cpf": masked_cpf,
            "vencimento_reciclagem": data_reciclagem.strftime('%Y-%m-%d'),
            "certificacoes": ", ".join(cursos),
            "soft_skills": ", ".join(soft_skills), 
            "perfil_comportamental": random.choice(feedbacks),
            "nota_performance": round(random.uniform(6.5, 10.0), 1),
            "cep_base": fake.postcode(),
            "escala_atual": random.choice(escalas_pool),
            "ultimo_posto": fake.company() + " - Unidade " + str(random.randint(1, 10))
        }
        vigilantes.append(vigilante)

    return pd.DataFrame(vigilantes)

def create_sample_scale(df_vigilantes):
    escala = df_vigilantes.head(10).copy()
    escala['posto_atual'] = "Posto Bancário Centro - Agência " + fake.city()
    escala['data_inicio_ferias'] = (datetime.now() + timedelta(days=2)).strftime('%Y-%m-%d')
    return escala[['id_funcional', 'nome_completo', 'posto_atual', 'data_inicio_ferias']]

if __name__ == "__main__":
    print("⏳ Iniciando geração da massa de dados sintéticos...")

    df_total = generate_vigilante_data(400)
    df_total.to_csv('base_vigilantes_ativos.csv', index=False, encoding='utf-8-sig')

    df_escala = create_sample_scale(df_total)
    df_escala.to_csv('escala_atual.csv', index=False, encoding='utf-8-sig')

    print(f"✅ Sucesso!")
    print(f"📂 Arquivo 'base_vigilantes_ativos.csv' criado com {len(df_total)} registros.")
    print(f"📂 Arquivo 'escala_atual.csv' criado para testes de substituição.")