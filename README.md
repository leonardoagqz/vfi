# VFI - Validador Fiscal Inteligente

[![CI/CD](https://github.com/leonardoagqz/vfi/actions/workflows/ci.yml/badge.svg)](https://github.com/leonardoagqz/vfi/actions)
![Delphi 12](https://img.shields.io/badge/Delphi-12-red)
![.NET 9](https://img.shields.io/badge/.NET-9-blue)
![VB6](https://img.shields.io/badge/VB6-COM%20DLL-purple)
![Tests](https://img.shields.io/badge/testes-10%2F10-brightgreen)
![DeepSeek](https://img.shields.io/badge/IA-DeepSeek-green)

**Sistema desktop de validacao fiscal com Clean Architecture, 55 regras fiscais com embasamento legal, IA (DeepSeek) e interoperabilidade VB6 COM.**

---

## Funcionalidades

| Funcionalidade | Descricao |
|---|---|
| **Importar XML** | Importa 1 ou varios NF-e/CT-e. Extrai emitente, destinatario, itens e impostos (ICMS, IPI, PIS, COFINS) direto do XML |
| **Validacao automatica** | CNPJ (14 digitos + DV), NCM (8 digitos), CFOP (1000-7999), chave fiscal (44 digitos + DV) |
| **Analise IA** | DeepSeek (ou motor local) analisa o documento contra regras fiscais do banco. Detecta padroes suspeitos com severidade |
| **55 regras fiscais** | Armazenadas no banco (AiRule) com severidade (CRITICO/ALERTA/INFO) e embasamento legal real (leis, decretos, convenios) |
| **CRUD de regras** | Adicionar, editar e excluir regras via API REST. Grid com busca e ordenacao por coluna |
| **Grade multisselecao** | Ctrl+Click/Shift+Click para selecionar varios documentos. Exclusao em lote |
| **Painel de detalhes** | Dados completos do documento, impostos extraidos por tipo com base/aliquota/valor/CST, lista de itens |
| **VB6 COM Interop** | Strategy Pattern: tenta carregar DLL VB6 via COM. Se nao registrada, usa fallback Pascal transparente |
| **Barra de progresso** | Feedback visual durante importacao e analise IA |

## Arquitetura (Clean Architecture)

```
Domain/          ← Entities, Enums, Interfaces (0 dependencias)
Data/            ← Config (.ini), ConnectionFactory, Repository Pattern
Services/        ← FiscalValidator, AIAnalyzer (DeepSeek), XmlImporter, VB6Bridge, TaxCalculator
UI/              ← MainForm (View fina) + MainController (Presenter MVP) + Constantes
AppModule        ← DI Container / Bootstrap
```

### Fluxo principal

```
Importar XML → TXmlImporter (parse DOM)
  → IFiscalDocumentRepository.Inserir() → SQL Server
  → IFiscalValidator.ValidarDocumento() → CNPJ/NCM/CFOP
  → AtualizarStatus() → VALIDO/REJEITADO

Analisar IA  → IAIAnalyzer.AnalisarDocumento()
  → BuildPrompt(Doc + 55 regras fiscais)
  → DeepSeek API ou analise local
  → Resultado: anomalias, confianca, recomendacoes
```

### Padroes de Projeto

| Padrao | Aplicacao |
|--------|----------|
| **Repository** | `IFiscalDocumentRepository` abstrai acesso a dados |
| **Dependency Injection** | `TMainController.Create(Repo, Validator, AI)` |
| **MVP** | Form (View) → Controller (Presenter) → Services |
| **Strategy** | `TVB6Bridge`: VB6 COM vs Pascal (fallback transparente) |
| **Factory** | `TConnectionFactory` centraliza criacao de conexoes ADO |
| **SOLID** | Cada classe = 1 responsabilidade |

## Tecnologias

| Camada | Stack |
|--------|-------|
| Desktop | Delphi 12 VCL + ADO + TListView + PageControl |
| Banco | SQL Server (ADO via ODBC DSN) |
| API | C# .NET 9 + EF Core + Swagger |
| IA | DeepSeek API + motor de analise local |
| XML | Delphi XML DOM (Xml.XMLDoc) |
| Legado | VB6 ActiveX DLL COM |
| Testes | xUnit 10/10 + DUnit + VB6 test module |
| CI/CD | GitHub Actions |

## Estrutura

```
vfi/
├── src/
│   ├── delphi/
│   │   ├── Domain/        ← Entities, Enums, Interfaces
│   │   ├── Data/           ← Config, Connection, Repository
│   │   ├── Services/       ← Validator, AIAnalyzer, XmlImporter, VB6Bridge, AppModule
│   │   ├── UI/             ← MainForm, MainController, Constantes
│   │   └── Resources/      ← vfi.ini, regras_fiscais.txt
│   ├── api/                ← C# .NET 9 Web API
│   │   ├── Controllers/    ← FiscalDocuments, AiRules
│   │   ├── Models/         ← AiRule, FiscalDocument, TaxCalculation
│   │   └── Services/       ← IAIntegrationService
│   ├── vb6/                ← VB6 ActiveX DLL fonte
│   ├── ia/                 ← Python IA (DeepSeek)
│   └── web/                ← Cliente web HTML
├── tests/                  ← xUnit (.NET)
├── sql/migrations/         ← Scripts SQL Server
├── .github/workflows/      ← CI/CD
├── iniciar-api.bat         ← Inicia API com 1 clique
├── parar-api.bat           ← Para API
└── README.md
```

## Como Executar

### Pre-requisitos
- SQL Server (LocalDB ou Express)
- .NET 9 SDK
- Delphi 12 (Alexandria)
- ODBC Driver 17 for SQL Server

### 1. Banco de Dados

```powershell
sqlcmd -S localhost -E -i sql/migrations/001_create_database.sql
```

### 2. API C# (porta 5000)

```powershell
# Windows: duplo clique em iniciar-api.bat
# Ou terminal:
cd src/api
dotnet run
# Swagger: http://localhost:5000/swagger
```

### 3. Delphi 12

```
File → Open → src/delphi/VFI.dpr → Build All → F9
```

### 4. Testes

```powershell
dotnet test tests/VfiApi.Tests.csproj
# Resultado: 10/10 passando
```

## API REST

| Metodo | Rota | Descricao |
|--------|------|-----------|
| GET | `/api/FiscalDocuments` | Listar documentos |
| POST | `/api/FiscalDocuments` | Criar documento |
| GET | `/api/AiRules?activeOnly=true` | Regras fiscais ativas |
| POST | `/api/AiRules` | Criar regra |
| PUT | `/api/AiRules/{id}` | Atualizar regra |
| DELETE | `/api/AiRules/{id}` | Excluir regra |

## Regras Fiscais com Embasamento Legal

55 regras armazenadas no banco (tabela `AiRule`) com:
- **Severidade**: CRITICO (bloqueante), ALERTA (risco moderado), INFO (informativo)
- **Embasamento Legal**: referencia a legislacao real (LC 87/96, Ajuste SINIEF, Convenios ICMS, STF)

Exemplos:
- `CRITICO` - Soma dos itens deve coincidir com valor total (Ajuste SINIEF 07/2005)
- `ALERTA` - NCM 8528 (monitores): ST obrigatoria em SP (Protocolo ICMS 191/2009)
- `INFO` - Lucro Real: PIS 1.65%, COFINS 7.6% (Lei 10.637/2002)

---

Desenvolvido por **Leonardo Aguiar** · [GitHub](https://github.com/leonardoagqz) · [LinkedIn](https://linkedin.com/in/leonardoagqz)
