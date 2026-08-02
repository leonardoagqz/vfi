unit VFI.Domain.Interfaces;

interface

uses
  System.SysUtils, System.Generics.Collections,
  VFI.Domain.Entities, VFI.Domain.Enums;

type
  TStatusCallback = procedure(const AMsg: string) of object;

  IFiscalDocumentRepository = interface
    function BuscarTodos: TObjectList<TFiscalDocument>;
    function BuscarPorId(const AId: Integer): TFiscalDocument;
    function BuscarPorFiltro(const ATipo: TTipoDocumento; const AStatus: string): TObjectList<TFiscalDocument>;
    procedure Inserir(const ADocument: TFiscalDocument);
    procedure AtualizarStatus(const AId: Integer; const AStatus: TStatusDocumento);
    procedure Excluir(const AId: Integer);
    procedure InserirCalculo(const ACalculo: TTaxCalculation);
    procedure InserirAnaliseIA(const ADocId: Integer; const AModelo, APrompt, AResposta: string;
      const AAnomalias: Integer; const AConfianca: Double);
  end;

  ITaxCalculator = interface
    ['{B2C3D4E5-F6A7-8901-BCDE-F12345678901}']
    function CalcularICMS(const AValorProduto, AAliquota, APercReducao,
      AFrete, ASeguro, AOutrasDesp, ADesconto: Double;
      const AOrigem: TOrigemMercadoria; const ARegime: TRegimeTributario): TResultadoCalculo;
    function CalcularICMSST(const AValorProduto, AAliquotaInterna,
      AAliquotaInterestadual, AMVA, AFrete, ASeguro, AOutrasDesp, ADesconto: Double): TResultadoCalculo;
    function CalcularIPI(const AValorProduto, AAliquota, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
    function CalcularPIS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
    function CalcularCOFINS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
    function CalcularDIFAL(const AValorProduto, AAliquotaDestino,
      AAliquotaInterestadual, APercPartilha, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
    function CalcularCargaTotal(const AValorProduto, AAliqICMS, AAliqIPI,
      AAliqPIS, AAliqCOFINS: Double; const ARegime: TRegimeTributario;
      const AFrete, ASeguro, AOutrasDesp, ADesconto: Double): Double;
  end;

  IFiscalValidator = interface
    ['{C3D4E5F6-A7B8-9012-CDEF-123456789012}']
    function ValidarCNPJ(const ACNPJ: string): Boolean;
    function ValidarChaveNFe(const AChave: string): Boolean;
    function ValidarNCM(const ANCM: string): Boolean;
    function ValidarCFOP(const ACFOP: string): Boolean;
    function ValidarDocumento(const ADocument: TFiscalDocument): TResultadoValidacao;
  end;

  IAIAnalyzer = interface
    ['{D4E5F6A7-B8C9-0123-DEFA-234567890123}']
    function AnalisarDocumento(const ADocument: TFiscalDocument): TResultadoIA;
  end;

  IMainController = interface
    ['{E5F6A7B8-C9D0-1234-EFAB-345678901234}']
    procedure Inicializar;
    procedure CarregarDocumentos;
    procedure ValidarDocumento(const AId: Integer);
    procedure CalcularImpostos(const AId: Integer);
    procedure AnalisarComIA(const AId: Integer);
    procedure ImportarXml(const AArquivo: string);
    procedure ImportarMultiplosXmls(const AArquivos: TArray<string>);
    procedure ExcluirDocumento(const AId: Integer);
    function ObterDocumento(const AIndex: Integer): TFiscalDocument;
    function QuantidadeDocumentos: Integer;
    procedure SetOnStatus(const AProc: TStatusCallback);
  end;

implementation

end.
