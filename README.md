# Azure Smart Staffing RAG 🛡️

Sistema Inteligente de Alocação de Vigilantes e Gestão de Férias utilizando arquitetura **RAG (Retrieval-Augmented Generation)**, focado em conformidade legal e otimização logística para o setor de segurança armada.

## 🚀 Objetivo

O projeto resolve o gargalo de realocação tática de colaboradores. Ele utiliza busca híbrida para encontrar o substituto ideal baseado em geolocalização, validade de reciclagem da Polícia Federal e cursos de extensão, utilizando o **GPT-4o** para justificar a escolha ao gestor de operações.

## 🛠️ Stack Tecnológica

* **Linguagem:** Python 3.11+
* **Framework:** FastAPI & LangChain
* **IA Generativa:** Azure OpenAI (GPT-4o & Text-Embeddings)
* **Busca Inteligente:** Azure AI Search (Hybrid Search & Scoring Profiles)
* **Infraestrutura:** Terraform (Modular Design) & Kubernetes (AKS)
* **Segurança:** Azure RBAC (Managed Identities) & Private Endpoints
* **CI/CD:** GitHub Actions
* **Dados:** Azure Blob Storage & Azure Functions (Event-Driven Ingestion)

---

## 🗺️ Roadmap de Desenvolvimento

### 1. Engenharia de Dados & Dataset (Camada Zero)

* [x] **Setup de Gerador Sintético:** Script Python utilizando biblioteca `Faker` para criação de massa de dados.
* [x] **Compliance LGPD (Data Masking):** Implementação de máscara em campos sensíveis (CPF: `785.***.***-30`) para proteção de PII.
* [x] **Dicionário de Dados:** Definição de atributos críticos (Certificações, Reciclagem PF e Geolocalização).
* [x] **Cenários de Teste:** Geração de arquivos `base_vigilantes_ativos.csv` (substitutos) e `escala_atual.csv` (operacional).

### 2. Infraestrutura como Código (Terraform Modular)

* [ ] **Setup de Provedores:** Configuração do Azure Provider e Backend Remoto para `.tfstate`.
* [ ] **Módulo de Cluster:** Provisionamento do **Azure Kubernetes Service (AKS)** e Container Registry (ACR).
* [ ] **Módulo de Storage:** Provisionamento de Blob Storage e Containers de Ingestão (`rh-uploads`).
* [ ] **Módulo de IA:** Deployment do Azure OpenAI e Azure AI Search (SKU Standard).
* [ ] **Módulo de Networking:** Configuração de VNet e Private Endpoints (Zero Trust).
* [ ] **Segurança RBAC:** Implementação de Managed Identities para acesso passwordless.

### 3. Ingestão e Processamento (Event-Driven ETL)

* [ ] **Azure Function (Blob Trigger):** Função Serverless para captura e processamento automático de CSVs.
* [ ] **Normalização:** Lógica de tratamento de dados brutos para formato JSON compatível com o Search.
* [ ] **Index Design:** Configuração de campos filtráveis, facetáveis e vetoriais (Embeddings).
* [ ] **Scoring Profiles:** Regras de negócio para boost de performance e proximidade.

### 4. Engine RAG & API (FastAPI no AKS)

* [ ] **Containerização:** Criação de Dockerfile otimizado para a API de orquestração.
* [ ] **Setup de API:** Servidor FastAPI com documentação Swagger e integração LangChain.
* [ ] **Retrieval Strategy:** Implementação de Busca Híbrida (Vetor + Keyword).
* [ ] **Orquestração LLM:** Síntese de resposta com GPT-4o e justificativa de escolha.

### 5. Automação e DevOps (GitHub Actions)

* [ ] **CI Pipeline:** Linting, Docker Build e Push para o ACR.
* [ ] **CD Pipeline:** Deploy automatizado no AKS com atualização de imagem.
* [ ] **IaC Pipeline:** Automação do ciclo de vida da infraestrutura via Terraform.

---

## 🏗️ Arquitetura do Sistema

1. **Ingestão (Serverless):** O upload do CSV para o **Blob Storage** dispara uma **Azure Function**. Esta função processa o arquivo e alimenta o índice do **Azure AI Search**.
2. **Orquestração (Containers):** A aplicação **FastAPI** roda em **Azure Kubernetes Service (AKS)**, garantindo escalabilidade e baixa latência para as consultas.
3. **Processo RAG:**
* O usuário solicita uma substituição via API.
* A API consulta o **AI Search** (Busca Híbrida) filtrando por compliance e relevância.
* Os resultados são enviados ao **Azure OpenAI** que gera a resposta final fundamentada.

---

## 🛠️ Guia de Execução Local

### 1. Geração da Massa de Dados

```bash
python -m venv venv
source venv/bin/activate  # venv\Scripts\activate no Windows
pip install -r requirements.txt
python scripts/data_generator.py

```

### 2. Provisionamento da Infraestrutura

```bash
cd terraform
terraform init
terraform apply -auto-approve

```

---

## 🔐 Segurança e Compliance

* **Zero Trust:** Comunicação entre AKS, Functions e Serviços de IA via **Managed Identities**.
* **Isolamento:** Uso de Private Endpoints para garantir que o tráfego de dados não transite pela internet pública.
* **LGPD:** Mascaramento de dados sensíveis na camada de geração de dataset sintético.

---

## 📁 Estrutura do Repositório

```text
├── .github/workflows/          # Automação de Infra e Deploy
├── terraform/                  # Módulos IaC (AKS, Storage, AI, Network)
├── scripts/
│   └── data_generator.py       # Gerador de massa de dados sintéticos
├── azure_functions/            # Ingestão assíncrona (Blob -> Search)
├── app/                        # FastAPI (Container): Lógica RAG e LangChain
└── README.md

```
