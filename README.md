# VFI - Validador Fiscal Inteligente

[![CI/CD](https://github.com/leonardoagqz/vfi/actions/workflows/ci.yml/badge.svg)](https://github.com/leonardoagqz/vfi/actions)
![Delphi 12](https://img.shields.io/badge/Delphi-12-red)
![.NET 9](https://img.shields.io/badge/.NET-9-blue)
![VB6](https://img.shields.io/badge/VB6-COM%20DLL-purple)
![Tests](https://img.shields.io/badge/testes-10%2F10-brightgreen)
![DeepSeek](https://img.shields.io/badge/IA-DeepSeek-green)

**Sistema desktop de validacao fiscal com Clean Architecture, 55 regras fiscais com embasamento legal, IA (DeepSeek) e interoperabilidade VB6 COM.**

---

## Para que serve

O VFI resolve um problema real de empresas que lidam com documentos fiscais eletronicos (NF-e, CT-e). Em vez do analista fiscal conferir manualmente cada campo de cada XML, o sistema:

1. **Importa** o XML e extrai automaticamente todos os dados (emitente, destinatario, itens, impostos)
2. **Valida** instantaneamente contra regras fiscais obrigatorias (CNPJ, NCM, CFOP, chave)
3. **Analisa** com IA (DeepSeek) usando 55 regras fiscais com embasamento legal real
4. **Mostra** tudo em uma interface profissional com grid, detalhes e logs

O resultado: o analista ve instantaneamente o que esta errado, por que esta errado e qual a base legal — sem precisar consultar legislacao manualmente.

---

## Funcionalidades

| Funcionalidade | Descricao | Valor para o usuario |
|---|---|---|
| **Importar XML** | Importa 1 ou varios NF-e/CT-e. Extrai emitente, destinatario, itens e impostos (ICMS, IPI, PIS, COFINS) | Elimina digitacao manual |
| **Validacao automatica** | CNPJ (14 digitos + DV), NCM (8 digitos), CFOP (1000-7999), chave (44 digitos + DV) | Detecta erros antes do envio a SEFAZ |
| **Analise IA** | DeepSeek + motor local analisam contra regras fiscais. Detecta divergencias, CFOP incompativel, valores suspeitos | Encontra problemas que um humano poderia deixar passar |
| **55 regras fiscais** | Armazenadas no banco com severidade (CRITICO/ALERTA/INFO) e embasamento legal real | Cada alerta tem base na legislacao vigente |
| **CRUD de regras** | Adicionar/Editar/Excluir via API REST. Grid com busca e ordenacao | Regras evolutivas — a empresa adiciona suas proprias |
| **Grade multisselecao** | Ctrl+Click/Shift+Click, exclusao em lote com confirmacao | Agilidade para limpar dados de teste |
| **Painel de detalhes** | Dados completos + impostos extraidos com base/aliquota/valor/CST + itens | Visao completa do documento em um so lugar |
| **VB6 COM Interop** | Strategy Pattern: tenta carregar DLL VB6. Fallback Pascal se nao registrada | Prova que legacy e moderno coexistem |
| **Progresso visual** | Barra na status bar + label "Processando... 2/5" | Feedback visual em operacoes demoradas |
| **Configuracao API** | InputBox para chave DeepSeek, salva em vfi.ini | Usuario controla quando usar IA real |

---

## Diagrama de Interoperabilidade

```
┌──────────────────────────────────────────────────────────┐
│                   Delphi 12 VCL (Desktop)                 │
│   Interface grafica: ListView, PageControl, ProgressBar  │
│   MVP Pattern: TfrmMain (View) + TMainController         │
└──────────┬──────────────────────────┬────────────────────┘
           │ COM Interop              │ HTTP REST
           ▼                          ▼
┌──────────────────────┐   ┌──────────────────────────────┐
│   VB6 ActiveX DLL    │   │     C# .NET 9 Web API        │
│  Calculo ICMS/ST/IPI │   │  CRUD Documentos + Regras    │
│  PIS/COFINS/DIFAL    │   │  Swagger / EF Core           │
│  (Strategy Pattern)  │   │  Endpoints REST documentados │
└──────────────────────┘   └──────────┬───────────────────┘
                                      │
                           ┌──────────▼───────────────────┐
                           │        SQL Server            │
                           │  VFI_DB: 6 tabelas           │
                           │  FiscalDocument, AiRule...   │
                           └──────────┬───────────────────┘
                                      │
                           ┌──────────▼───────────────────┐
                           │     Integracao IA            │
                           │  DeepSeek API (nuvem)        │
                           │  + Motor local (offline)     │
                           │  55 regras fiscais           │
                           └──────────────────────────────┘
```

**Como as stacks se comunicam:**

1. **Delphi → VB6**: `CreateOleObject('FiscalEngine.FiscalCalculator')` — COM Interop nativo
2. **Delphi → C# API**: `THTTPClient.Get/Post/Put/Delete` — REST em `localhost:5000`
3. **C# API → SQL Server**: Entity Framework Core com migrations
4. **Delphi → SQL Server**: ADO direto via ODBC DSN (para performance)
5. **Delphi → DeepSeek**: `THTTPClient.Post` com JSON — mesmo padrao da API OpenAI
6. **C# API → DeepSeek**: `HttpClient` com prompt incluindo regras do banco

---

## Arquitetura (Clean Architecture)

O codigo e organizado em 4 camadas com dependencias unidirecionais. Cada camada so conhece a camada abaixo dela. Isso permite testar, manter e evoluir cada parte isoladamente.

```
┌─────────────────────────────────────────────┐
│  UI/                                        │  ← Apresentacao
│  TfrmMain (View) + TMainController (MVP)    │     Sabe desenhar a tela
│  O Form NAO tem logica de negocio           │     Nao sabe validar, nao sabe salvar
└──────────────────┬──────────────────────────┘
                   │ depende de
┌──────────────────▼──────────────────────────┐
│  Services/                                  │  ← Logica de Negocio
│  FiscalValidator, AIAnalyzer, XmlImporter   │     Sabe validar, analisar, importar
│  TVB6Bridge, TaxCalculator, AppModule       │     Nao sabe como salvar no banco
└──────────────────┬──────────────────────────┘
                   │ depende de
┌──────────────────▼──────────────────────────┐
│  Data/                                      │  ← Acesso a Dados
│  Repository, ConnectionFactory, Config      │     Sabe INSERT, SELECT, UPDATE
│  Conexao ADO com SQL Server                 │     Nao sabe regras de negocio
└──────────────────┬──────────────────────────┘
                   │ depende de
┌──────────────────▼──────────────────────────┐
│  Domain/                                    │  ← Nucleo do Sistema
│  Entities, Enums, Interfaces                │     Nao depende de nada externo
│  Zero dependencias de banco, UI ou framework│     Pode ser testado isoladamente
└─────────────────────────────────────────────┘
```

### Domain/ — O que o sistema E

Define **o que** o sistema e, sem se preocupar com **como** funciona:

| Arquivo | Conteudo | Exemplo |
|---------|----------|---------|
| `Entities.pas` | Classes que representam dados do negocio | `TFiscalDocument` (Id, Chave, Emitente, Itens, Impostos) |
| `Enums.pas` | Tipos enumerados do dominio fiscal | `TTipoDocumento` (NFe, CTe), `TStatusDocumento` (Pendente, Validado) |
| `Interfaces.pas` | Contratos que as outras camadas devem cumprir | `IFiscalDocumentRepository` (BuscarTodos, Inserir, Excluir) |

**Por que existe:** Se amanha trocar SQL Server por Oracle, zero codigo do Domain muda. So implementa uma nova classe que cumpre `IFiscalDocumentRepository`.

### Data/ — Como os dados sao persistidos

Implementa os contratos definidos no Domain:

| Arquivo | Responsabilidade | Detalhe |
|---------|-----------------|---------|
| `Config.pas` | Le configuracoes externas | Le `vfi.ini` (servidor, usuario, senha, chave API) |
| `Connection.pas` | Fabrica de conexoes ADO | `TConnectionFactory.CriarConexao` retorna `TADOConnection` pronta |
| `Repository.pas` | Todas as operacoes de banco | INSERT, SELECT, UPDATE, DELETE com SQL parametrizado via `Format()` + escaping |

**Por que existe:** Isola todo o codigo SQL em um unico lugar. Se precisar trocar a forma de conectar (ex: FireDAC em vez de ADO), so mexe aqui.

### Services/ — Logica de negocio

Onde as regras fiscais realmente acontecem:

| Servico | O que faz | Exemplo |
|---------|-----------|---------|
| `FiscalValidator` | Valida CNPJ, NCM, CFOP, chave NFe | Algoritmo do digito verificador modulo 11 |
| `AIAnalyzer` | Integracao com DeepSeek + analise local | Monta prompt com documento + 55 regras → envia para IA |
| `XmlImporter` | Parse de XML fiscal (DOM) | Extrai `<emit>`, `<dest>`, `<det>`, `<imposto>` do XML |
| `VB6Bridge` | Strategy Pattern para DLL VB6 | `CreateOleObject('FiscalEngine.FiscalCalculator')` com fallback |
| `TaxCalculator` | Calculos fiscais em Pascal | ICMS, ST, IPI, PIS, COFINS, DIFAL |
| `AppModule` | DI Container / Bootstrap | Inicializa todos os servicos e injeta dependencias |

**Por que existe:** Cada regra fiscal e testavel isoladamente. `TFiscalValidator` recebe um `TFiscalDocument` e retorna `TResultadoValidacao` — puramente funcional, zero dependencia de banco ou UI.

### UI/ — O que o usuario ve

A camada mais fina possivel — so desenha a tela e captura eventos:

| Componente | Responsabilidade | O que NAO faz |
|-----------|-----------------|---------------|
| `TfrmMain` (View) | ListView, PageControl, botoes, eventos de clique | NAO valida, NAO salva, NAO analisa |
| `TMainController` (Presenter) | Orquestra o fluxo: Form → Services → Form | NAO desenha tela, NAO acessa banco direto |
| `Constantes.pas` | Cores, paths, endpoints | Evita magic numbers espalhados |

**Por que existe:** O Form e "burro" — so delega. Quando o usuario clica "Validar", o Form chama `Controller.ValidarDocumento()`, que chama `Validator.ValidarDocumento()`, que chama `Repository.AtualizarStatus()`. O Form so atualiza a grid no final.

---

## Padroes de Projeto

| Padrao | Onde | Por que |
|--------|------|--------|
| **Repository** | `IFiscalDocumentRepository` | Abstrai banco → testa servicos sem SQL |
| **Dependency Injection** | `TMainController.Create(Repo, Validator, AI)` | Troca implementacoes sem alterar Controller |
| **MVP** | Form → Controller → Services | UI nao tem logica, facil de testar |
| **Strategy** | `TVB6Bridge`: VB6 vs Pascal | Engine de calculo trocavel sem alterar cliente |
| **Factory** | `TConnectionFactory.CriarConexao` | Centraliza configuracao de conexao |
| **SOLID** | Cada classe = 1 motivo pra mudar | Manutencao e evolucao independentes |

---

## Fluxo Completo: Importar → Validar → IA

```
1. Usuario clica "Importar" → seleciona XML(s)
2. TXmlImporter.parseia o XML → extrai emitente, itens, impostos
3. IFiscalDocumentRepository.Inserir() → salva no SQL Server
4. IFiscalValidator.ValidarDocumento() → CNPJ/NCM/CFOP/Chave
5. Status: APROVADO (verde) ou REJEITADO (vermelho)
6. Grid atualiza automaticamente

7. Usuario seleciona documento → ve detalhes, itens, impostos
8. Clica "Analisar com IA"
9. IAIAnalyzer monta prompt: dados do doc + 55 regras fiscais
10. Envia para DeepSeek (ou analisa localmente)
11. Resultado: [CRITICO] CFOP invalido, [ALERTA] NCM sem ST...
12. Exibe na tab Analise IA com severidade e recomendacoes
```

---

## Regras Fiscais com Embasamento Legal

55 regras na tabela `AiRule` do SQL Server. Cada regra tem:

| Campo | Descricao | Exemplo |
|-------|-----------|---------|
| `Description` | Texto da regra | "NCM 8528 (monitores): ST obrigatoria em SP" |
| `Severity` | CRITICO, ALERTA, INFO | ALERTA |
| `Referencia` | Base legal real | "Protocolo ICMS 191/2009; Portaria CAT-SP" |
| `IsActive` | Regra ativa/desativada | true |

**Categorias:** ICMS (18 regras), IPI (5), PIS/COFINS (6), CFOP (6), NCM (5), Validacao (9), Limiares (6).

As regras sao carregadas via `GET /api/AiRules?activeOnly=true` e usadas pela IA como contexto. O usuario pode adicionar/editar/excluir regras pela interface — as alteracoes sao salvas no banco via API REST.

---

## Tecnologias

| Camada | Stack | Justificativa |
|--------|-------|---------------|
| Desktop | Delphi 12 VCL + ADO + TListView | Stack principal da vaga |
| Banco | SQL Server (ADO via ODBC DSN) | OLE DB nativo, zero dependencia de BPL |
| API | C# .NET 9 + EF Core + Swagger | REST documentada, testavel |
| IA | DeepSeek API + motor local offline | Mais barato que OpenAI, mesmo padrao de API |
| XML | Delphi XML DOM (Xml.XMLDoc) | Nativo, sem bibliotecas externas |
| Legado | VB6 ActiveX DLL (COM Interop) | Prova de interoperabilidade legacy↔moderno |
| Testes | xUnit 10/10 + DUnit + VB6 test module | Cobertura em todas as camadas |
| CI/CD | GitHub Actions | Build + testes automaticos a cada push |

---

## Estrutura de Arquivos

```
vfi/
├── src/
│   ├── delphi/
│   │   ├── VFI.dpr                    ← Bootstrap (Application.CreateForm)
│   │   ├── Domain/
│   │   │   ├── Entities.pas           ← TFiscalDocument, TDocumentItem, TTaxCalculation
│   │   │   ├── Enums.pas              ← TTipoDocumento, TStatusDocumento, TTipoImposto
│   │   │   └── Interfaces.pas         ← IFiscalDocumentRepository, IMainController, IAIAnalyzer
│   │   ├── Data/
│   │   │   ├── Config.pas             ← TAppConfig (leitura de vfi.ini)
│   │   │   ├── Connection.pas         ← TConnectionFactory (ADO via ODBC DSN)
│   │   │   └── Repository.pas        ← TFiscalDocumentRepository (SQL via ADO)
│   │   ├── Services/
│   │   │   ├── AppModule.pas          ← DI Container / Bootstrap
│   │   │   ├── FiscalValidator.pas    ← Validacao CNPJ, NCM, CFOP, Chave NFe
│   │   │   ├── AIAnalyzer.pas         ← DeepSeek API + SimulateAnalysis local
│   │   │   ├── XmlImporter.pas        ← Parser XML (DOM) com extracao de impostos
│   │   │   ├── TaxCalculator.pas      ← Calculos ICMS, ST, IPI, PIS, COFINS, DIFAL
│   │   │   └── VB6Bridge.pas          ← COM Interop (Strategy Pattern)
│   │   ├── UI/
│   │   │   ├── MainForm.pas/.dfm      ← TfrmMain (View) - ListView, PageControl
│   │   │   ├── MainController.pas     ← TMainController (Presenter/MVP)
│   │   │   └── Constantes.pas         ← Cores, paths, endpoints
│   │   └── Resources/
│   │       ├── vfi.ini                ← Configuracao (DB, API key)
│   │       └── regras_fiscais.txt     ← Fallback offline
│   ├── api/                           ← C# .NET 9 Web API
│   │   ├── Controllers/               ← FiscalDocumentsController, AiRulesController
│   │   ├── Models/                    ← AiRule, FiscalDocument, TaxCalculation
│   │   ├── Data/                      ← VfiDbContext (EF Core)
│   │   └── Services/                  ← IAIntegrationService
│   ├── vb6/                           ← VB6 ActiveX DLL (fonte)
│   │   ├── dll/                       ← FiscalCalculator.cls, modValidators.bas
│   │   └── tests/                     ← TestFiscalCalculator.bas
│   ├── ia/                            ← Python IA
│   │   └── vfi_ai.py                  ← Script standalone (DeepSeek)
│   └── web/                           ← Cliente web HTML
│       └── index.html
├── tests/                             ← xUnit (.NET)
├── sql/
│   └── migrations/                    ← Criacao do banco (001_create_database.sql)
├── docs/xml-exemplos/                 ← 9 XMLs para teste
├── .github/workflows/                 ← CI/CD (ci.yml)
├── iniciar-api.bat                    ← Inicia API com 1 clique
├── parar-api.bat                      ← Para API
└── README.md
```

---

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
# Duplo clique em: iniciar-api.bat
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
# Resultado: 10/10 passando em ~200ms
```

---

## API REST

| Metodo | Rota | Descricao |
|--------|------|-----------|
| GET | `/api/FiscalDocuments` | Listar documentos com paginacao |
| POST | `/api/FiscalDocuments` | Criar documento fiscal |
| POST | `/api/FiscalDocuments/{id}/validate` | Validar documento |
| POST | `/api/FiscalDocuments/{id}/analyze-ai` | Analisar com IA |
| GET | `/api/AiRules?activeOnly=true` | Regras fiscais ativas |
| POST | `/api/AiRules` | Criar regra fiscal |
| PUT | `/api/AiRules/{id}` | Atualizar regra |
| DELETE | `/api/AiRules/{id}` | Excluir regra (soft-delete) |

Swagger interativo: http://localhost:5000/swagger

---

## CI/CD (GitHub Actions)

Pipeline em `.github/workflows/ci.yml`. Executa automaticamente a cada `git push`:

1. **Build & Test**: compila API .NET + executa 10 testes xUnit
2. **VB6 Validation**: verifica sintaxe dos arquivos `.bas`/`.cls`/`.vbp`
3. **SQL Validation**: valida scripts `.sql`
4. **Code Coverage**: Coverlet + ReportGenerator

URL: https://github.com/leonardoagqz/vfi/actions

---

Desenvolvido por **Leonardo Aguiar** · [GitHub](https://github.com/leonardoagqz) · [LinkedIn](https://linkedin.com/in/leonardoagqz)
