unit VFI.Services.TaxCalculator;

interface

uses
  System.SysUtils, System.Math,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TTaxCalculator = class(TInterfacedObject, ITaxCalculator)
  private
    function Round2(const AValue: Double): Currency;
    function Round4(const AValue: Double): Double;
  public
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

implementation

function TTaxCalculator.Round2(const AValue: Double): Currency;
begin
  Result := System.Math.RoundTo(AValue, -2);
end;

function TTaxCalculator.Round4(const AValue: Double): Double;
begin
  Result := System.Math.RoundTo(AValue, -4);
end;

function TTaxCalculator.CalcularICMS(const AValorProduto, AAliquota, APercReducao,
  AFrete, ASeguro, AOutrasDesp, ADesconto: Double;
  const AOrigem: TOrigemMercadoria; const ARegime: TRegimeTributario): TResultadoCalculo;
var
  BaseNormal, BaseCalculo: Double;
begin
  FillChar(Result, SizeOf(Result), 0);

  if AValorProduto <= 0 then
  begin
    Result.Sucesso := False;
    Result.MensagemErro := 'Valor do produto deve ser maior que zero';
    Exit;
  end;

  BaseNormal := AValorProduto + AFrete + ASeguro + AOutrasDesp - ADesconto;

  if APercReducao > 0 then
  begin
    BaseCalculo := BaseNormal * (1 - (APercReducao / 100));
    Result.PercentualReducao := APercReducao;
    Result.ValorBaseReduzida := Round2(BaseCalculo);
  end
  else
  begin
    BaseCalculo := BaseNormal;
    Result.PercentualReducao := 0;
    Result.ValorBaseReduzida := 0;
  end;

  Result.Sucesso := True;
  Result.TipoImposto := tiICMS;
  Result.BaseCalculo := Round2(BaseCalculo);
  Result.Aliquota := AAliquota;
  Result.ValorImposto := Round2(BaseCalculo * (AAliquota / 100));
  Result.CST := '00';
  Result.CFOP := '5101';
  Result.Engine := ecInternal;
end;

function TTaxCalculator.CalcularICMSST(const AValorProduto, AAliquotaInterna,
  AAliquotaInterestadual, AMVA, AFrete, ASeguro, AOutrasDesp, ADesconto: Double): TResultadoCalculo;
var
  BaseNormal, BaseST, ICMSProprio, ValorST: Double;
begin
  FillChar(Result, SizeOf(Result), 0);

  if AValorProduto <= 0 then
  begin
    Result.Sucesso := False;
    Result.MensagemErro := 'Valor do produto deve ser maior que zero';
    Exit;
  end;

  BaseNormal := AValorProduto + AFrete + ASeguro + AOutrasDesp - ADesconto;
  ICMSProprio := BaseNormal * (AAliquotaInterestadual / 100);
  BaseST := BaseNormal * (1 + (AMVA / 100));
  ValorST := (BaseST * (AAliquotaInterna / 100)) - ICMSProprio;
  if ValorST < 0 then ValorST := 0;

  Result.Sucesso := True;
  Result.TipoImposto := tiICMSST;
  Result.BaseCalculo := Round2(BaseST);
  Result.Aliquota := AAliquotaInterna;
  Result.ValorImposto := Round2(ValorST);
  Result.CST := '60';
  Result.CFOP := '5405';
  Result.Engine := ecInternal;
end;

function TTaxCalculator.CalcularIPI(const AValorProduto, AAliquota, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
var
  BaseIPI: Double;
begin
  FillChar(Result, SizeOf(Result), 0);

  if AValorProduto <= 0 then
  begin
    Result.Sucesso := False;
    Result.MensagemErro := 'Valor do produto deve ser maior que zero';
    Exit;
  end;

  BaseIPI := AValorProduto + AFrete + ASeguro + AOutrasDesp;

  Result.Sucesso := True;
  Result.TipoImposto := tiIPI;
  Result.BaseCalculo := Round2(BaseIPI);
  Result.Aliquota := AAliquota;
  Result.ValorImposto := Round2(BaseIPI * (AAliquota / 100));
  Result.CST := '50';
  Result.CFOP := '5101';
  Result.Engine := ecInternal;
end;

function TTaxCalculator.CalcularPIS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  FillChar(Result, SizeOf(Result), 0);

  if AValorProduto <= 0 then
  begin
    Result.Sucesso := False;
    Result.MensagemErro := 'Valor do produto deve ser maior que zero';
    Exit;
  end;

  Result.Sucesso := True;
  Result.TipoImposto := tiPIS;
  Result.BaseCalculo := Round2(AValorProduto);
  Result.Aliquota := AAliquota;
  Result.ValorImposto := Round2(AValorProduto * (AAliquota / 100));
  Result.CFOP := '5101';
  Result.Engine := ecInternal;

  case ARegime of
    rtLucroReal:        Result.CST := '01';
    rtLucroPresumido:   Result.CST := '04';
    rtSimplesNacional:  Result.CST := '49';
  end;
end;

function TTaxCalculator.CalcularCOFINS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  FillChar(Result, SizeOf(Result), 0);

  if AValorProduto <= 0 then
  begin
    Result.Sucesso := False;
    Result.MensagemErro := 'Valor do produto deve ser maior que zero';
    Exit;
  end;

  Result.Sucesso := True;
  Result.TipoImposto := tiCOFINS;
  Result.BaseCalculo := Round2(AValorProduto);
  Result.Aliquota := AAliquota;
  Result.ValorImposto := Round2(AValorProduto * (AAliquota / 100));
  Result.CFOP := '5101';
  Result.Engine := ecInternal;

  case ARegime of
    rtLucroReal:        Result.CST := '01';
    rtLucroPresumido:   Result.CST := '04';
    rtSimplesNacional:  Result.CST := '49';
  end;
end;

function TTaxCalculator.CalcularDIFAL(const AValorProduto, AAliquotaDestino,
  AAliquotaInterestadual, APercPartilha, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
var
  Base, ICMSInterestadual, ICMSTotal, Diferencial, ParcelaDestino: Double;
begin
  FillChar(Result, SizeOf(Result), 0);

  if AValorProduto <= 0 then
  begin
    Result.Sucesso := False;
    Result.MensagemErro := 'Valor do produto deve ser maior que zero';
    Exit;
  end;

  Base := AValorProduto + AFrete + ASeguro + AOutrasDesp;
  ICMSInterestadual := Base * (AAliquotaInterestadual / 100);
  ICMSTotal := Base * (AAliquotaDestino / 100);
  Diferencial := ICMSTotal - ICMSInterestadual;
  if Diferencial < 0 then Diferencial := 0;
  ParcelaDestino := Diferencial * (APercPartilha / 100);

  Result.Sucesso := True;
  Result.TipoImposto := tiDIFAL;
  Result.BaseCalculo := Round2(Base);
  Result.Aliquota := AAliquotaDestino - AAliquotaInterestadual;
  Result.ValorImposto := Round2(ParcelaDestino);
  Result.CST := '90';
  Result.CFOP := '6102';
  Result.Engine := ecInternal;
end;

function TTaxCalculator.CalcularCargaTotal(const AValorProduto, AAliqICMS, AAliqIPI,
  AAliqPIS, AAliqCOFINS: Double; const ARegime: TRegimeTributario;
  const AFrete, ASeguro, AOutrasDesp, ADesconto: Double): Double;
var
  Res: TResultadoCalculo;
begin
  Result := 0;

  Res := CalcularICMS(AValorProduto, AAliqICMS, 0, AFrete, ASeguro, AOutrasDesp, ADesconto, omNacional, ARegime);
  if Res.Sucesso then Result := Result + Res.ValorImposto;

  Res := CalcularIPI(AValorProduto, AAliqIPI, AFrete, ASeguro, AOutrasDesp);
  if Res.Sucesso then Result := Result + Res.ValorImposto;

  Res := CalcularPIS(AValorProduto, AAliqPIS, ARegime);
  if Res.Sucesso then Result := Result + Res.ValorImposto;

  Res := CalcularCOFINS(AValorProduto, AAliqCOFINS, ARegime);
  if Res.Sucesso then Result := Result + Res.ValorImposto;

  Result := Round2(Result);
end;

end.
