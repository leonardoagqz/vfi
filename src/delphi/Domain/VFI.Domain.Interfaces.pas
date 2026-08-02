unit VFI.Domain.Interfaces;

interface

uses
  System.SysUtils, System.Generics.Collections,
  VFI.Domain.Entities, VFI.Domain.Enums;

type
  TStatusCallback = procedure(const AMsg: string) of object;

  IFiscalDocumentRepository = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function BuscarTodos: TObjectList<TFiscalDocument>;
    function BuscarPorId(const AIdentificador: Integer): TFiscalDocument;
    function BuscarPorFiltro(const ATipo: TTipoDocumento; const AStatus: string): TObjectList<TFiscalDocument>;
    procedure Inserir(const ADocument: TFiscalDocument);
    procedure AtualizarStatus(const AIdentificador: Integer; const AStatus: TStatusDocumento);
    procedure Excluir(const AIdentificador: Integer);
    function ExisteChave(const AChave: string): Boolean;
    procedure InserirCalculo(const ACalculo: TTaxCalculation);
    procedure InserirAnaliseIA(const ADocId: Integer; const AModelo, APrompt, AResposta: string;
      const AAnomalias: Integer; const AConfianca: Double);
  end;

  IFiscalValidator = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    function ValidarCNPJ(const ACNPJ: string): Boolean;
    function ValidarNCM(const ANCM: string): Boolean;
    function ValidarCFOP(const ACFOP: string): Boolean;
    function ValidarDocumento(const ADocument: TFiscalDocument): TResultadoValidacao;
  end;

  IAIAnalyzer = interface
    ['{D4E5F6A7-B8C9-0123-DEFA-234567890123}']
    function AnalisarDocumento(const ADocument: TFiscalDocument): TResultadoIA;
    procedure SetRegrasFiscais(const ARegras: string);
  end;

  TAiRuleRecord = record
    Id: Integer;
    Description: string;
    Severity: string;
    IsActive: Boolean;
    UpdatedAt: string;
    Referencia: string;
  end;
  TArrayOfAiRule = TArray<TAiRuleRecord>;

  IMainController = interface
    ['{E5F6A7B8-C9D0-1234-EFAB-345678901234}']
    procedure Inicializar;
    procedure CarregarDocumentos;
    procedure ImportarXml(const AArquivo: string);
    procedure ImportarMultiplosXmls(const AArquivos: TArray<string>);
    procedure ExcluirDocumento(const AId: Integer);
    procedure AnalisarComIA(const AId: Integer);
    function ObterDocumento(const AIndex: Integer): TFiscalDocument;
    function QuantidadeDocumentos: Integer;
    procedure SetOnStatus(const AProc: TStatusCallback);
    function ObterUltimoResultadoIA: TResultadoIA;
    function ObterUltimaValidacao: TResultadoValidacao;
    procedure SetRegrasFiscais(const ARegras: string);
    procedure ConfigurarAPI(const AApiKey, AEndpoint, AModel: string);
    function ValidarDocumentoAtual(const ADoc: TFiscalDocument): TResultadoValidacao;
    function ListarRegrasIA: TArrayOfAiRule;
    procedure AdicionarRegraIA(const ADescricao, ASeveridade, AReferencia: string);
    procedure AtualizarRegraIA(const AId: Integer; const ADescricao, ASeveridade, AReferencia: string);
    procedure ExcluirRegraIA(const AId: Integer);
  end;

implementation

end.
