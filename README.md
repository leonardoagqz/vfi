# VFI - Validador Fiscal Inteligente

[![CI/CD](https://github.com/leonardoagqz/vfi/actions/workflows/ci.yml/badge.svg)](https://github.com/leonardoagqz/vfi/actions)
![Delphi 12](https://img.shields.io/badge/Delphi-12-red)
![.NET 9](https://img.shields.io/badge/.NET-9-blue)
![VB6](https://img.shields.io/badge/VB6-COM%20DLL-purple)
![Tests](https://img.shields.io/badge/testes-10%2F10-brightgreen)
![DeepSeek](https://img.shields.io/badge/IA-DeepSeek-green)

**Sistema desktop de validacao fiscal com Clean Architecture, 55 regras com embasamento legal, IA (DeepSeek) e interoperabilidade VB6 COM.**

---

## Diagrama de Interoperabilidade

```
┌──────────────────────────────────────────────────────────┐
│                   Delphi 12 VCL (Desktop)                 │
│   MVP: TfrmMain (View) + TMainController (Presenter)     │
└──────────┬──────────────────────────┬────────────────────┘
           │ COM Interop              │ HTTP REST
           ▼                          ▼
┌──────────────────────┐   ┌──────────────────────────────┐
│   VB6 ActiveX DLL    │   │     C# .NET 9 Web API        │
│  ICMS/ST/IPI/PIS/    │   │  CRUD + Validacao + IA       │
│  COFINS/DIFAL (COM)  │   │  Swagger / EF Core           │
└──────────────────────┘   └──────────┬───────────────────┘
                                      │
                           ┌──────────▼───────────────────┐
                           │        SQL Server            │
                           │  VFI_DB (6 tabelas + AiRule) │
                           └──────────┬───────────────────┘
                                      │
                           ┌──────────▼───────────────────┐
                           │     Integracao IA            │
                           │  DeepSeek API + motor local  │
                           │  55 regras fiscais ativas    │
                           └──────────────────────────────┘
```

---

## Funcionalidades

- **Importar XML** — 1 ou varios NF-e/CT-e. Extrai emitente, itens e impostos automaticamente
- **Validar** — CNPJ, NCM, CFOP, chave fiscal com algoritmos de digito verificador
- **Analisar IA** — DeepSeek ou motor local analisa contra 55 regras fiscais com severidade
- **Regras editaveis** — CRUD via API REST. 55 regras com embasamento legal real (LC 87/96, Ajuste SINIEF, STF)
- **Grade profissional** — multisselecao, status colorido, exclusao em lote, busca, ordenacao
- **VB6 COM Interop** — Strategy Pattern: DLL VB6 ou fallback Pascal transparente
- **Progresso visual** — barra na status bar durante importacao e analise

---

## Arquitetura (Clean Architecture)

```
Domain/     ← Entities, Enums, Interfaces (0 dependencias)
Data/       ← Config (.ini), ConnectionFactory, Repository (ADO + SQL Server)
Services/   ← Validator, AIAnalyzer (DeepSeek), XmlImporter, VB6Bridge, TaxCalculator
UI/         ← MainForm (View) + MainController (Presenter MVP)
AppModule   ← DI Container / Bootstrap
```

### Camadas

| Camada | O que faz | Exemplo |
|--------|-----------|---------|
| **Domain** | Define o que o sistema E — zero dependencias | `IFiscalDocumentRepository`, `TFiscalDocument` |
| **Data** | Persiste e recupera dados — SQL via ADO | `TFiscalDocumentRepository.BuscarTodos()` |
| **Services** | Regras de negocio — testaveis isoladamente | `TFiscalValidator.ValidarCNPJ('11222333000181')` |
| **UI** | Desenha a tela — zero logica de negocio | `TfrmMain` → `TMainController` → Services |

### Padroes

| Padrao | Onde |
|--------|------|
| **Repository** | `IFiscalDocumentRepository` |
| **Dependency Injection** | `TMainController.Create(Repo, Validator, AI)` |
| **MVP** | Form → Controller → Services |
| **Strategy** | `TVB6Bridge` (VB6 COM vs Pascal) |
| **Factory** | `TConnectionFactory` |

---

## Fluxo do Usuario

```
Importar XML → Validacao automatica → Ver detalhes/impostos → Analisar IA → Resultado com severidade
```

1. Importa XML → sistema extrai dados + impostos + valida CNPJ/NCM/CFOP
2. Grid mostra status colorido (APROVADO/REJEITADO)
3. Seleciona documento → ve detalhes, itens, impostos extraidos
4. Clica "Analisar IA" → DeepSeek analisa contra 55 regras
5. Resultado: anomalias com severidade e recomendacao

---

## Regras Fiscais

55 regras no banco (`AiRule`) com severidade e embasamento legal:

| Exemplo | Severidade | Base Legal |
|---------|-----------|------------|
| Soma itens deve coincidir com valor total | CRITICO | Ajuste SINIEF 07/2005 |
| NCM 8528 (monitores): ST obrigatoria SP | ALERTA | Protocolo ICMS 191/2009 |
| Lucro Real: PIS 1.65%, COFINS 7.6% | INFO | Lei 10.637/2002 |
| Exclusao ICMS da base PIS/COFINS | INFO | STF, RE 574.706/PR |
| NF-e > R$100k exige MDF-e | ALERTA | Ajuste SINIEF 21/2010 |

---

## Estrutura

```
vfi/
├── src/
│   ├── delphi/           ← App desktop (Domain/Data/Services/UI)
│   ├── api/              ← C# .NET 9 REST API
│   ├── vb6/              ← VB6 ActiveX DLL fonte
│   ├── ia/               ← Python IA (DeepSeek)
│   └── web/              ← Cliente HTML
├── tests/                ← xUnit (10/10)
├── sql/migrations/       ← Scripts SQL Server
├── .github/workflows/    ← CI/CD
├── iniciar-api.bat       ← Inicia API com 1 clique
└── parar-api.bat         ← Para API
```

---

## Tecnologias

| Camada | Stack |
|--------|-------|
| Desktop | Delphi 12 VCL + ADO |
| Banco | SQL Server (ADO via ODBC) |
| API | C# .NET 9 + EF Core + Swagger |
| IA | DeepSeek API + motor local |
| XML | Delphi XML DOM |
| Legado | VB6 ActiveX DLL COM |
| Testes | xUnit 10/10 |
| CI/CD | GitHub Actions |

---

## Como Executar

```powershell
# 1. Banco
sqlcmd -S localhost -E -i sql/migrations/001_create_database.sql

# 2. API (porta 5000)
cd src/api && dotnet run

# 3. Delphi 12
File → Open → src/delphi/VFI.dpr → Build All → F9

# 4. Testes
dotnet test tests/VfiApi.Tests.csproj   # 10/10 passando
```

---

Desenvolvido por **Leonardo Aguiar** · [GitHub](https://github.com/leonardoagqz) · [LinkedIn](https://linkedin.com/in/leonardoagqz)
