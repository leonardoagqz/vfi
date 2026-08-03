unit VFI.Domain.Entities;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  VFI.Domain.Enums;

type
  TDocumentItem = class;
  TTaxCalculation = class;

  TFiscalDocument = class
  private
    FId: Integer;
    FTipo: TTipoDocumento;
    FChave: string;
    FNumero: string;
    FDataEmissao: TDateTime;
    FCnpjEmitente: string;
    FNomeEmitente: string;
    FCnpjDestinatario: string;
    FNomeDestinatario: string;
    FUFEmitente: string;
    FMunicipioEmitente: string;
    FUFDestinatario: string;
    FMunicipioDestinatario: string;
    FValorTotal: Currency;
    FXmlContent: string;
    FStatus: TStatusDocumento;
    FParecerIA: string;
    FItens: TObjectList<TDocumentItem>;
    FCalculos: TObjectList<TTaxCalculation>;
  public
    constructor Create;
    destructor Destroy; override;
    property Id: Integer read FId write FId;
    property Tipo: TTipoDocumento read FTipo write FTipo;
    property Chave: string read FChave write FChave;
    property Numero: string read FNumero write FNumero;
    property DataEmissao: TDateTime read FDataEmissao write FDataEmissao;
    property CnpjEmitente: string read FCnpjEmitente write FCnpjEmitente;
    property NomeEmitente: string read FNomeEmitente write FNomeEmitente;
    property CnpjDestinatario: string read FCnpjDestinatario write FCnpjDestinatario;
    property NomeDestinatario: string read FNomeDestinatario write FNomeDestinatario;
    property UFEmitente: string read FUFEmitente write FUFEmitente;
    property MunicipioEmitente: string read FMunicipioEmitente write FMunicipioEmitente;
    property UFDestinatario: string read FUFDestinatario write FUFDestinatario;
    property MunicipioDestinatario: string read FMunicipioDestinatario write FMunicipioDestinatario;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
    property XmlContent: string read FXmlContent write FXmlContent;
    property Status: TStatusDocumento read FStatus write FStatus;
    property ParecerIA: string read FParecerIA write FParecerIA;
    property Itens: TObjectList<TDocumentItem> read FItens;
    property Calculos: TObjectList<TTaxCalculation> read FCalculos;
  end;

  TDocumentItem = class
  private
    FId: Integer;
    FDocumentId: Integer;
    FCodigoProduto: string;
    FNomeProduto: string;
    FNCM: string;
    FCFOP: string;
    FQuantidade: Double;
    FValorUnitario: Currency;
    FValorTotal: Currency;
    FCST: string;
  public
    property Id: Integer read FId write FId;
    property DocumentId: Integer read FDocumentId write FDocumentId;
    property CodigoProduto: string read FCodigoProduto write FCodigoProduto;
    property NomeProduto: string read FNomeProduto write FNomeProduto;
    property NCM: string read FNCM write FNCM;
    property CFOP: string read FCFOP write FCFOP;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property ValorUnitario: Currency read FValorUnitario write FValorUnitario;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
    property CST: string read FCST write FCST;
  end;

  TTaxCalculation = class
  private
    FId: Integer;
    FDocumentId: Integer;
    FItemId: Integer;
    FTipoImposto: TTipoImposto;
    FBaseCalculo: Currency;
    FAliquota: Double;
    FValorImposto: Currency;
    FEngine: TEngineCalculo;
    FCST: string;
    FCFOP: string;
  public
    property Id: Integer read FId write FId;
    property DocumentId: Integer read FDocumentId write FDocumentId;
    property ItemId: Integer read FItemId write FItemId;
    property TipoImposto: TTipoImposto read FTipoImposto write FTipoImposto;
    property BaseCalculo: Currency read FBaseCalculo write FBaseCalculo;
    property Aliquota: Double read FAliquota write FAliquota;
    property ValorImposto: Currency read FValorImposto write FValorImposto;
    property Engine: TEngineCalculo read FEngine write FEngine;
    property CST: string read FCST write FCST;
    property CFOP: string read FCFOP write FCFOP;
  end;

  TResultadoCalculo = record
    Sucesso: Boolean;
    MensagemErro: string;
    TipoImposto: TTipoImposto;
    BaseCalculo: Currency;
    Aliquota: Double;
    ValorImposto: Currency;
    ValorBaseReduzida: Currency;
    PercentualReducao: Double;
    CST: string;
    CFOP: string;
    Engine: TEngineCalculo;
  end;

  TResultadoValidacao = class
  private
    FIsValid: Boolean;
    FErros: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    property IsValid: Boolean read FIsValid write FIsValid;
    property Erros: TStringList read FErros;
    function ErrosAsString: string;
  end;

  TResultadoIA = record
    Sucesso: Boolean;
    Modelo: string;
    Prompt: string;
    Resposta: string;
    AnomaliasEncontradas: Integer;
    Confianca: Double;
    TokensUtilizados: Integer;
  end;

implementation

constructor TFiscalDocument.Create;
begin
  inherited;
  FItens := TObjectList<TDocumentItem>.Create(True);
  FCalculos := TObjectList<TTaxCalculation>.Create(True);
  FStatus := stPendente;
end;

destructor TFiscalDocument.Destroy;
begin
  FItens.Free;
  FCalculos.Free;
  inherited;
end;

constructor TResultadoValidacao.Create;
begin
  inherited;
  FIsValid := True;
  FErros := TStringList.Create;
end;

destructor TResultadoValidacao.Destroy;
begin
  FErros.Free;
  inherited;
end;

function TResultadoValidacao.ErrosAsString: string;
begin
  Result := FErros.Text;
end;

end.
