# VFI - Validador Fiscal Inteligente

[![CI/CD Pipeline](https://github.com/leonardoagqz/vfi/actions/workflows/ci.yml/badge.svg)](https://github.com/leonardoagqz/vfi/actions/workflows/ci.yml)

**Sistema de validacao fiscal multi-tecnologia com DLL VB6, API C# .NET, app Delphi VCL e IA integrada.**

---

## Arquitetura

```
┌──────────────────────────────────────────────────────┐
│                 Delphi VCL (Desktop)                  │
│   Interface grafica + chamadas COM para DLL VB6      │
└──────────┬──────────────────────────┬────────────────┘
           │ COM Interop              │ HTTP REST
           ▼                          ▼
┌──────────────────────┐   ┌──────────────────────────┐
│   VB6 ActiveX DLL    │   │   C# .NET 9 Web API      │
│  Calculo ICMS/ST/IPI │   │  CRUD + Validacao + IA   │
│  PIS/COFINS/DIFAL    │   │  Swagger / EF Core       │
└──────────────────────┘   └──────────┬───────────────┘
                                      │
                           ┌──────────▼───────────────┐
                           │     SQL Server           │
                           │   VFI_DB (Fiscal)        │
                           └──────────────────────────┘
                                      │
                           ┌──────────▼───────────────┐
                           │   Integracao IA          │
                           │  OpenAI / Azure / Sim.   │
                           └──────────────────────────┘
```

## Tecnologias

| Camada | Tecnologia |
|--------|-----------|
| **Desktop** | Delphi VCL + FireDAC |
| **Legado Fiscal** | Visual Basic 6 (ActiveX DLL COM) |
| **API Backend** | C# .NET 9 + ASP.NET Core |
| **Banco de Dados** | SQL Server + Entity Framework Core |
| **Testes** | xUnit (.NET) + DUnit (Delphi) + VB6 Test Module |
| **IA** | OpenAI API / Azure OpenAI / Modo Simulacao |
| **CI/CD** | GitHub Actions |
| **Docs API** | Swagger / OpenAPI |

## Estrutura do Projeto

```
vfi/
├── src/
│   ├── delphi/              # App Desktop Delphi VCL
│   │   ├── VFI.dpr          # Project file
│   │   ├── forms/           # Formularios (frmMain)
│   │   ├── modules/         # DataModules + servicos
│   │   └── tests/           # DUnit tests
│   ├── vb6/                 # DLL VB6 (COM)
│   │   ├── dll/             # Codigo fonte da DLL
│   │   │   ├── FiscalEngine.vbp
│   │   │   ├── FiscalCalculator.cls
│   │   │   └── modValidators.bas
│   │   └── tests/           # Teste unitario VB6
│   ├── api/                 # API C# .NET 9
│   │   ├── Controllers/     # Endpoints REST
│   │   ├── Models/          # Entity Framework
│   │   ├── Services/        # Logica de negocio
│   │   ├── DTOs/            # Objetos de transferencia
│   │   └── Data/            # DbContext
│   └── ia/                  # Integracao IA (Python)
├── tests/                   # Testes xUnit (.NET)
├── sql/
│   ├── migrations/          # Scripts SQL Server
│   └── seeds/               # Dados de exemplo
├── docs/                    # Documentacao
├── .github/workflows/       # CI/CD
└── README.md
```

## Funcionalidades

### Modulo Fiscal (VB6 DLL)
- **ICMS**: calculo com reducao de base, frete, seguro, despesas e desconto
- **ICMS-ST**: substituicao tributaria com MVA (Margem de Valor Agregado)
- **IPI**: imposto sobre produtos industrializados
- **PIS/COFINS**: regime lucro real, presumido e simples nacional
- **DIFAL**: diferencial de aliquota interestadual com partilha
- **Carga Total**: somatorio de todos os impostos sobre um item
- **Validacao**: CNPJ, chave NFe, CFOP, NCM

### API REST (C# .NET)
- `GET    /api/FiscalDocuments` - Listar documentos (com filtros e paginacao)
- `GET    /api/FiscalDocuments/{id}` - Detalhes do documento
- `POST   /api/FiscalDocuments` - Criar documento fiscal
- `POST   /api/FiscalDocuments/{id}/validate` - Validar documento
- `POST   /api/FiscalDocuments/{id}/analyze-ai` - Analisar com IA
- `POST   /api/FiscalDocuments/{id}/calculate-tax` - Calcular impostos

### App Desktop (Delphi VCL)
- Grid de documentos fiscais com filtros
- Importacao de XML (NF-e, CT-e, MDF-e)
- Validacao fiscal com log de eventos
- Calculo de impostos via DLL VB6 (COM Interop)
- Analise IA integrada com OpenAI/Azure
- Dashboard de status e alertas

### IA Integration
- Analise fiscal automatizada com LLMs
- Suporte a OpenAI API e Azure OpenAI Service
- Modo simulacao offline para desenvolvimento
- Identificacao de anomalias: CFOP x NCM, valores suspeitos, prazos
- Script Python standalone (`src/ia/vfi_ai.py`)

## Como Executar

### Pre-requisitos
- SQL Server (LocalDB ou instancia completa)
- .NET 9 SDK
- Delphi (RAD Studio) com FireDAC
- Visual Basic 6 (para compilar a DLL)
- Python 3.10+ (para modulo IA)

### 1. Banco de Dados

```sql
-- Executar no SQL Server Management Studio
sql/migrations/001_create_database.sql
sql/seeds/seed_data.sql
```

### 2. API C#

```bash
cd src/api
cp appsettings.json appsettings.Development.json
# Ajustar connection string em appsettings.Development.json
dotnet run
# Acessar Swagger: http://localhost:5000/swagger
```

### 3. DLL VB6

```
1. Abrir src/vb6/dll/FiscalEngine.vbp no VB6 IDE
2. Compilar (File > Make FiscalEngine.dll)
3. Registrar: regsvr32 FiscalEngine.dll
```

### 4. App Delphi

```
1. Abrir src/delphi/VFI.dpr no Delphi IDE
2. Configurar FireDAC connection (dmVFI.pas)
3. Compilar e executar
```

### 5. IA (Python)

```bash
# Modo simulacao (nao requer API key)
python src/ia/vfi_ai.py --document-id 1 --simulate

# Com OpenAI
set VFI_AI_API_KEY=sk-...
python src/ia/vfi_ai.py --document-id 1 --provider openai

# Com Azure
set VFI_AI_API_KEY=...
set VFI_AZURE_ENDPOINT=https://seu-recurso.openai.azure.com
python src/ia/vfi_ai.py --document-id 1 --provider azure --model gpt-4
```

### 6. Testes

```bash
# .NET xUnit
dotnet test tests/VfiApi.Tests.csproj

# VB6: Abrir TestFiscalCalculator.bas no VB6 e executar TestAll()
# Delphi: Executar DUnit via IDE
```

## CI/CD

O pipeline GitHub Actions executa:

1. **Build & Test**: compila API .NET e roda xUnit
2. **VB6 Validation**: verifica sintaxe dos arquivos VB6
3. **SQL Validation**: valida scripts SQL
4. **Code Analysis**: cobertura de codigo com Coverlet + ReportGenerator

## Diferenciais para a Vaga

Este projeto demonstra dominio pratico em:

- **Delphi VCL** com FireDAC, COM Interop, VCL Forms, DataModules
- **Visual Basic 6** ActiveX DLL com calculos fiscais reais (ICMS, ST, IPI, PIS, COFINS, DIFAL)
- **C# .NET** Web API com Entity Framework Core, Swagger, arquitetura em camadas
- **SQL Server** com migrations, indices, foreign keys e seeds
- **IA/LLMs** integrados ao fluxo de validacao fiscal (OpenAI + Azure)
- **CI/CD** com GitHub Actions e cobertura de testes automatizada
- **Interoperabilidade** Delphi ↔ VB6 (COM) ↔ C# (REST) ↔ IA (API)

---

Desenvolvido por **Leonardo Aguiar** · [GitHub](https://github.com/leonardoagqz) · [LinkedIn](https://linkedin.com/in/leonardoagqz)
