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

### 1. Criação do Dataset

* [x] **Setup de Gerador Sintético:** Script Python utilizando biblioteca `Faker` para criação de massa de dados.
* [x] **Compliance LGPD (Data Masking):** Implementação de máscara em campos sensíveis (CPF: `785.***.***-30`) para proteção de PII.
* [x] **Dicionário de Dados:** Definição de atributos críticos (Certificações, Reciclagem PF, Soft Skills e CEP).
* [x] **Cenários de Teste:** Geração de arquivos `base_vigilantes_ativos.csv` e `escala_atual.csv`.

### 2. Infraestrutura como Código (Terraform Modular)

* [x] **Setup de Provedores:** Configuração do Azure Provider e Backend Remoto para `.tfstate`.
* [x] **Módulo de Cluster:** Provisionamento do **Azure Kubernetes Service (AKS)** e Container Registry (ACR).
* [x] **Módulo de Storage:** Provisionamento de Blob Storage e Containers de Ingestão (`rh-uploads`).
* [x] **Módulo de IA:** Deployment do Azure OpenAI e Azure AI Search (SKU Standard).
* [x] **Módulo de Networking:** Configuração de VNet e isolamento de rede.
* [x] **Segurança RBAC:** Implementação de Managed Identities para acesso passwordless.
* [x] **Módulo de Serverless:** Provisionamento de **Azure Functions** para pipeline de enriquecimento.

### 3. Ingestão e Enriquecimento (AI Pipeline)

* [ ] **Azure Function (Custom Skill):** Desenvolvimento de API Serverless para geocodificação (CEP -> Lat/Long) seguindo o contrato de interface do AI Search.
* [ ] **AI Search Skillset:** Configuração do pipeline de enriquecimento que orquestra a chamada da Function e a extração de metadados.
* [ ] **Index Design (Geospatial & Vector):** Configuração de campos `Edm.GeographyPoint` para busca por proximidade e `Collection(Single)` para busca vetorial de Soft Skills.
* [ ] **Indexer & DataSource:** Automação da varredura do Blob Storage (`rh-uploads`) para sincronização e vetorização automática de novos perfis.

### 4. Engine RAG & API (FastAPI & LangChain)

* [ ] **Containerização:** Criação de Dockerfile multi-stage para otimização de imagem da API.
* [ ] **Kubernetes Manifests:** Configuração de Deployments e Services.
* [ ] **Orquestração com LangChain:** Implementação de **Chains** para fluxo Pergunta -> Retrieval -> Prompt -> GPT-4o.
* [ ] **Retrieval Strategy:** Implementação de **Busca Híbrida** (Vetorial + Keyword) e Re-ranking semântico.
* [ ] **Setup de API (FastAPI):** Endpoints para solicitação de substituição e integração com Workload Identity.

### 5. Automação, DevOps & Observabilidade

* [ ] **ConfigMaps & Secrets:** Injeção de variáveis de ambiente seguras via Kubernetes.
* [ ] **CI Pipeline:** Automação de Linting, Docker Build e Push para o ACR via GitHub Actions.
* [ ] **CD Pipeline:** Deploy automatizado no AKS (GitOps approach).
* [ ] **IaC Pipeline:** Automação do ciclo de vida da infraestrutura via Terraform.

---

## 🏗️ Arquitetura do Sistema

1. **Ingestão e Enriquecimento (Event-Driven):**
* O upload do CSV dispara uma **Azure Function**.
* Durante a indexação no **AI Search**, uma **Custom Skill** converte o CEP em coordenadas geográficas, enriquecendo o perfil do vigilante sem intervenção manual do RH.


2. **Orquestração e Runtime (Kubernetes):**
* A aplicação **FastAPI** é executada em **Azure Kubernetes Service (AKS)**, utilizando manifestos de **Deployment** para garantir alta disponibilidade.
* A segurança é garantida via **Workload Identity**, permitindo que o Pod se autentique nos serviços de IA sem chaves de API.


3. **Processo RAG Inteligente (LangChain):**
* O **LangChain** atua como o motor de orquestração:
* **Retrieval:** Realiza a Busca Híbrida no **AI Search** aplicando filtros de compliance (Reciclagem), geolocalização (Geo-filtering) e relevância (Busca Vetorial por Soft Skills).
* **Augmentation:** Monta um prompt contextualizado injetando o perfil dos candidatos encontrados.
* **Generation:** O **GPT-4o** gera uma justificativa humanizada, comparando as Soft Skills do colaborador com os requisitos do posto (ex: "Perfil comunicativo ideal para posto escolar").


---

## 🛠️ Guia de Configuração da Infraestrutura (Início Rápido)

Este guia detalha como subir toda a infraestrutura na Azure utilizando Terraform.

### 1. Pré-requisitos
* **Azure CLI** instalado e logado (`az login`).
* **Terraform** (v1.0+) instalado.
* **Docker Desktop** rodando.
* **Assinatura Azure** ativa.

### 2. Passo a Passo Inicial

#### A. Bootstrap (Preparação do Cofre)
O Terraform precisa de um lugar seguro para guardar o estado da sua infraestrutura. Execute o script de automação inicial:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

*Este script criará um Resource Group chamado `rg-terraform-state`. **Anote o nome da Storage Account gerada no final.***

#### B. Configuração do Backend
Abra o arquivo `terraform/main.tf` e atualize o bloco `backend "azurerm"` com o nome da Storage Account gerada:

```hcl
backend "azurerm" {
  resource_group_name  = "rg-terraform-state"
  storage_account_name = "ST_GERADA_AQUI"
  container_name       = "tfstate"
  key                  = "smart-staffing.terraform.tfstate"
}
```

#### C. Provisionamento (Deploy)
Agora, dispare a criação de todos os recursos:

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

## 🛠️ Guia de Execução Local

### 1. Geração da Massa de Dados

```bash
python -m venv venv
source venv/bin/activate  # venv\Scripts\activate no Windows
pip install -r requirements.txt
python scripts/data_generator.py

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
terraform/
├── main.tf            # Orquestrador dos módulos
├── variables.tf       # Variáveis globais
├── outputs.tf         # Outputs principais
├── modules/
│   ├── network/       # VNet, Subnets, Private Endpoints
│   ├── storage/       # Blob Storage
│   ├── aks/           # Azure Kubernetes Service
│   └── ai/            # Azure OpenAI e Azure AI Search
│   └── functions/     # Azure Functions
├── scripts/
│   └── data_generator.py       # Gerador de massa de dados sintéticos
├── azure_functions/            # Ingestão assíncrona (Blob -> Search)
├── app/                        # FastAPI (Container): Lógica RAG e LangChain
└── README.md

```
