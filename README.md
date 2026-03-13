# Azure Smart Staffing RAG 🛡️

![Status: Work In Progress](https://img.shields.io/badge/Status-Work%20In%20Progress-orange?style=for-the-badge&logo=github)

Sistema Inteligente de Alocação de Vigilantes e Gestão de Férias utilizando arquitetura **RAG (Retrieval-Augmented Generation)**, focado em conformidade legal e otimização logística para o setor de segurança armada.

## 🚀 Objetivo

O projeto resolve o gargalo de realocação tática de colaboradores. Ele processa dados brutos de RH e utiliza AI Enrichment para converter CEPs em coordenadas geográficas, permitindo buscas híbridas que combinam conformidade legal (Polícia Federal), proximidade logística e análise de Soft Skills (perfil comportamental) para encontrar o substituto ideal. O GPT-4o é utilizado para justificar a escolha ao gestor de operações com base em dados técnicos e qualitativos.

## 🛠️ Stack Tecnológica

* **Linguagem:** Python 3.11+
* **Framework:** FastAPI & LangChain
* **IA Generativa:** Azure OpenAI (GPT-4o & Text-Embeddings)
* **Busca Inteligente**: Azure AI Search (Hybrid Search, Skillsets & Scoring Profiles)
* **Infraestrutura:** Terraform (Modular Design) & Kubernetes (AKS)
* **Segurança:** Azure RBAC (Managed Identities) & Private Endpoints
* **CI/CD:** GitHub Actions
* **Dados:** Azure Blob Storage & Azure Functions (Event-Driven Ingestion)

---

## 🗺️ Roadmap de Desenvolvimento

### 1. Engenharia de Dados & Dataset (Camada Zero)

* [x] **Setup de Gerador Sintético:** Script Python utilizando biblioteca `Faker` para criação de massa de dados.
* [x] **Compliance LGPD (Data Masking):** Implementação de máscara em campos sensíveis (CPF: `785.***.***-30`) para proteção de PII.
* [x] **Dicionário de Dados:** Definição de atributos críticos (Certificações, Reciclagem PF, Soft Skills e CEP).
* [x] **Cenários de Teste:** Geração de arquivos `base_vigilantes_ativos.csv` (substitutos) e `escala_atual.csv` (operacional).

### 2. Infraestrutura como Código (Terraform Modular)

* [ ] **Setup de Provedores:** Configuração do Azure Provider e Backend Remoto para `.tfstate`.
* [ ] **Módulo de Cluster:** Provisionamento do **Azure Kubernetes Service (AKS)** e Container Registry (ACR).
* [ ] **Módulo de Storage:** Provisionamento de Blob Storage e Containers de Ingestão (`rh-uploads`).
* [ ] **Módulo de IA:** Deployment do Azure OpenAI e Azure AI Search (SKU Standard).
* [ ] **Módulo de Networking:** Configuração de VNet e Private Endpoints (Zero Trust).
* [ ] **Segurança RBAC:** Implementação de Managed Identities para acesso passwordless.

### 3. Ingestão e Enriquecimento (AI Pipeline) 

* [ ] **Azure Function (Custom Skill):** Desenvolvimento de função Serverless para geocodificação (CEP -> Lat/Long).
* [ ] **AI Search Skillset:** Configuração do pipeline de enriquecimento para processar dados geoespaciais e vetoriais.
* [ ] **Index Design:** Configuração de campos filtráveis, facetáveis e tipo `Edm.GeographyPoint`.
* [ ] **Scoring Profiles:** Regras de negócio para priorizar proximidade e aderência ao perfil (Soft Skills).

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

## 🏗️ Arquitetura do Sistema

1. **Ingestão e Enriquecimento:** O upload do CSV dispara uma **Azure Function**. Durante a indexação no **AI Search**, uma **Custom Skill** converte o CEP em coordenadas geográficas, enriquecendo o perfil do vigilante sem intervenção manual do RH. 
2. **Orquestração:** A aplicação **FastAPI** (AKS) recebe a solicitação de substituição.
3. **Processo RAG:**
* A API consulta o **AI Search** buscando por: 
    1. Validade de Reciclagem (Filtro);
    2. Proximidade (Geo);
    3. Perfil Comportamental (Vetor);
* Os resultados (ex: Top 3 candidatos) são enviados ao **Azure OpenAI**.
* O GPT-4o gera uma justificativa humanizada, explicando por que aquele colaborador é o melhor para aquele posto específico (ex: "Perfil comunicativo ideal para posto escolar"). 

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
