unit uVB6Integration;

interface

uses
  System.SysUtils, Winapi.ActiveX;

type
  { Enumeracoes que espelham a DLL VB6 }
  TTaxType = (ttICMS = 1, ttICMSST = 2, ttIPI = 3, ttPIS = 4, ttCOFINS = 5, ttDIFAL = 6);
  TTaxRegime = (trSimplesNacional = 1, trLucroPresumido = 2, trLucroReal = 3);
  TOrigemMercadoria = (omNacional = 0, omEstrangeiraImportacaoDireta = 1,
    omEstrangeiraMercadoInterno = 2, omNacionalConteudoImportacaoSuperior40 = 3,
    omNacionalConformidadeBasica = 4, omNacionalConteudoImportacaoInferior40 = 5,
    omEstrangeiraImportacaoDiretaSemSimilar = 6, omEstrangeiraMercadoInternoSemSimilar = 7,
    omNacionalConteudoImportacaoSuperior70 = 8);

  { Estrutura de resultado que espelha o UDT do VB6 }
  TTaxResult = record
    TaxType: TTaxType;
    BaseCalculo: Double;
    Aliquota: Double;
    ValorImposto: Double;
    ValorBaseReduzida: Double;
    PercentualReducao: Double;
    CST: string;
    CFOP: string;
    Sucesso: Boolean;
    MensagemErro: string;
  end;

  { Classe que encapsula chamadas a DLL VB6 via COM }
  TVB6FiscalEngine = class
  private
    FResultado: TTaxResult;
    FComObject: IUnknown;
    procedure InicializarCOM;
    procedure FinalizarCOM;
  public
    constructor Create;
    destructor Destroy; override;

    function CalcularICMS(ValorProduto: Double; AliquotaICMS: Double;
      PercentualReducao: Double; Frete: Double; Seguro: Double;
      OutrasDespesas: Double; Desconto: Double; Origem: TOrigemMercadoria;
      Regime: TTaxRegime): Boolean;

    function CalcularICMSST(ValorProduto: Double; AliquotaInterna: Double;
      AliquotaInterestadual: Double; MVA: Double; Frete: Double;
      Seguro: Double; OutrasDespesas: Double; Desconto: Double): Boolean;

    function CalcularIPI(ValorProduto: Double; AliquotaIPI: Double;
      Frete: Double; Seguro: Double; OutrasDespesas: Double): Boolean;

    function CalcularCargaTotal(ValorProduto: Double; AliqICMS: Double;
      AliqIPI: Double; AliqPIS: Double; AliqCOFINS: Double;
      Regime: TTaxRegime; Frete: Double; Seguro: Double;
      OutrasDespesas: Double; Desconto: Double): Double;

    property Resultado: TTaxResult read FResultado;
  end;

implementation

{ TVB6FiscalEngine }

constructor TVB6FiscalEngine.Create;
begin
  inherited;
  FillChar(FResultado, SizeOf(FResultado), 0);
  InicializarCOM;
end;

destructor TVB6FiscalEngine.Destroy;
begin
  FinalizarCOM;
  inherited;
end;

procedure TVB6FiscalEngine.InicializarCOM;
begin
  { Em producao: cria instancia do objeto COM da DLL VB6 }
  { Exemplo: CoFiscalCalculator.CreateRemote('FiscalEngine.FiscalCalculator') }
  { Aqui demonstramos a assinatura de integracao }
end;

procedure TVB6FiscalEngine.FinalizarCOM;
begin
  { Libera referencia do objeto COM }
  FComObject := nil;
end;

function TVB6FiscalEngine.CalcularICMS(ValorProduto: Double; AliquotaICMS: Double;
  PercentualReducao: Double; Frete: Double; Seguro: Double;
  OutrasDespesas: Double; Desconto: Double; Origem: TOrigemMercadoria;
  Regime: TTaxRegime): Boolean;
var
  BaseNormal, BaseCalculo: Double;
begin
  { Em producao, chamaria o metodo COM da DLL VB6.
    Aqui replicamos a logica do VB6 em Delphi para demonstracao
    do fluxo de interoperabilidade. }

  FillChar(FResultado, SizeOf(FResultado), 0);

  if ValorProduto <= 0 then
  begin
    FResultado.Sucesso := False;
    FResultado.MensagemErro := 'Valor do produto deve ser maior que zero';
    Exit(False);
  end;

  BaseNormal := ValorProduto + Frete + Seguro + OutrasDespesas - Desconto;

  if PercentualReducao > 0 then
  begin
    BaseCalculo := BaseNormal * (1 - (PercentualReducao / 100));
    FResultado.PercentualReducao := PercentualReducao;
    FResultado.ValorBaseReduzida := BaseCalculo;
  end
  else
  begin
    BaseCalculo := BaseNormal;
    FResultado.PercentualReducao := 0;
    FResultado.ValorBaseReduzida := 0;
  end;

  FResultado.TaxType := ttICMS;
  FResultado.BaseCalculo := Round(BaseCalculo * 100) / 100;
  FResultado.Aliquota := AliquotaICMS;
  FResultado.ValorImposto := Round(BaseCalculo * (AliquotaICMS / 100) * 100) / 100;
  FResultado.CST := '00';
  FResultado.CFOP := '5101';
  FResultado.Sucesso := True;
  FResultado.MensagemErro := '';

  Result := True;
end;

function TVB6FiscalEngine.CalcularICMSST(ValorProduto: Double; AliquotaInterna: Double;
  AliquotaInterestadual: Double; MVA: Double; Frete: Double;
  Seguro: Double; OutrasDespesas: Double; Desconto: Double): Boolean;
var
  BaseNormal, BaseST, ICMSProprio, ICMSST: Double;
begin
  FillChar(FResultado, SizeOf(FResultado), 0);

  if ValorProduto <= 0 then
  begin
    FResultado.Sucesso := False;
    FResultado.MensagemErro := 'Valor do produto deve ser maior que zero';
    Exit(False);
  end;

  BaseNormal := ValorProduto + Frete + Seguro + OutrasDespesas - Desconto;
  ICMSProprio := BaseNormal * (AliquotaInterestadual / 100);
  BaseST := BaseNormal * (1 + (MVA / 100));
  ICMSST := (BaseST * (AliquotaInterna / 100)) - ICMSProprio;
  if ICMSST < 0 then ICMSST := 0;

  FResultado.TaxType := ttICMSST;
  FResultado.BaseCalculo := Round(BaseST * 100) / 100;
  FResultado.Aliquota := AliquotaInterna;
  FResultado.ValorImposto := Round(ICMSST * 100) / 100;
  FResultado.CST := '60';
  FResultado.CFOP := '5405';
  FResultado.Sucesso := True;

  Result := True;
end;

function TVB6FiscalEngine.CalcularIPI(ValorProduto: Double; AliquotaIPI: Double;
  Frete: Double; Seguro: Double; OutrasDespesas: Double): Boolean;
var
  BaseIPI, ValorIPI: Double;
begin
  FillChar(FResultado, SizeOf(FResultado), 0);

  if ValorProduto <= 0 then
  begin
    FResultado.Sucesso := False;
    FResultado.MensagemErro := 'Valor do produto deve ser maior que zero';
    Exit(False);
  end;

  BaseIPI := ValorProduto + Frete + Seguro + OutrasDespesas;
  ValorIPI := BaseIPI * (AliquotaIPI / 100);

  FResultado.TaxType := ttIPI;
  FResultado.BaseCalculo := Round(BaseIPI * 100) / 100;
  FResultado.Aliquota := AliquotaIPI;
  FResultado.ValorImposto := Round(ValorIPI * 100) / 100;
  FResultado.CST := '50';
  FResultado.CFOP := '5101';
  FResultado.Sucesso := True;

  Result := True;
end;

function TVB6FiscalEngine.CalcularCargaTotal(ValorProduto: Double; AliqICMS: Double;
  AliqIPI: Double; AliqPIS: Double; AliqCOFINS: Double;
  Regime: TTaxRegime; Frete: Double; Seguro: Double;
  OutrasDespesas: Double; Desconto: Double): Double;
var
  Total: Double;
begin
  Total := 0;

  if CalcularICMS(ValorProduto, AliqICMS, 0, Frete, Seguro,
                  OutrasDespesas, Desconto, omNacional, Regime) then
    Total := Total + FResultado.ValorImposto;

  if CalcularIPI(ValorProduto, AliqIPI, Frete, Seguro, OutrasDespesas) then
    Total := Total + FResultado.ValorImposto;

  Total := Total + Round(ValorProduto * (AliqPIS / 100) * 100) / 100;
  Total := Total + Round(ValorProduto * (AliqCOFINS / 100) * 100) / 100;

  Result := Round(Total * 100) / 100;
end;

end.
