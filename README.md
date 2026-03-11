# Azure-SmartStaffing-RAG 🛡️

### Sistema Inteligente de Alocação de Vigilantes e Gestão de Férias com IA Generativa

Este projeto implementa uma arquitetura **RAG (Retrieval-Augmented Generation)** de ponta a ponta para resolver um dos maiores gargalos logísticos em empresas de segurança patrimonial e facilities: a **realocação tática de colaboradores para cobertura de férias e faltas**.

## 📖 O Cenário de Negócio

Em operações de segurança armada, a substituição de um vigilante não é apenas uma questão de escala, mas de **conformidade legal**. O sistema automatiza o "match" entre o posto e o substituto ideal, processando planilhas de RH para garantir que critérios como vencimento de reciclagem (Polícia Federal), cursos de extensão (VSPP, Escolta), geolocalização e performance sejam respeitados em milissegundos.

## 🛠️ Stack Tecnológica & Requisitos Técnicos

O projeto demonstra proficiência nos requisitos de nível enterprise exigidos:

* **IA Generativa:** Azure OpenAI (GPT-4o) para síntese e Embeddings para busca semântica.
* **Busca Inteligente:** **Azure AI Search** com design de índices complexos, filtros e **Hybrid Search** (Keyword + Vetores).
* **Engine:** FastAPI orquestrando o fluxo RAG com LangChain.
* **Segurança (Zero Trust):** Implementação de **Private Endpoints**, **Managed Identities (RBAC)** e isolamento de rede via VNet.
* **Infraestrutura:** 100% via **Terraform** e deploy automatizado por **GitHub Actions**.

## 🏗️ Arquitetura do Sistema

1. **Ingestão:** Planilhas CSV geradas pelo RH são carregadas no **Azure Blob Storage**.
2. **Trigger & ETL:** Uma **Azure Function** detecta o upload, normaliza os dados e os envia para o índice.
3. **Indexação:** O **Azure AI Search** vetoriza os perfis e armazena metadados técnicos.
4. **Consumo:** O gestor consulta o **FastAPI**, que busca o melhor candidato e gera a justificativa via LLM.

## 📁 Estrutura do Repositório

```text
├── .github/workflows/          # CI/CD: Terraform e App Deploy
├── terraform/                  # IaC: Infraestrutura de Rede e Serviços AI
├── scripts/
│   └── data_generator.py       # Gerador de dados sintéticos para testes (LGPD Compliance)
├── azure_functions/            # Ingestão serverless de CSV para o Search
├── app/                        # FastAPI: Orquestrador RAG e LangChain
└── README.md

```

## 🛡️ Segurança e Compliance

* **Managed Identities (RBAC):** Comunicação entre serviços via Identidade Gerenciada, eliminando chaves (secrets) expostas no código.
* **Azure Private Link:** Tráfego de dados entre Storage, Function e Search isolado da internet pública.
* **Audit Log:** Rastreabilidade completa de todas as consultas realizadas no motor de recomendação.

---

## 🛠️ Comandos de Execução Local

Vá para a raiz do projeto no terminal e siga o fluxo abaixo para validar o microserviço:

```bash
# 1. Configurar o ambiente Python
python -m venv venv

# No Linux ou macOS
source venv/bin/activate
# No Windows (Prompt de Comando - CMD)
venv\Scripts\activate
# No Windows (PowerShell)
.\venv\Scripts\Activate.ps1

pip install -r app/requirements.txt

```
