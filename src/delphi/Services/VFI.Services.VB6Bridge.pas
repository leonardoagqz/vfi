unit VFI.Services.VB6Bridge;

interface

uses
  System.SysUtils, System.Win.ComObj, Winapi.ActiveX,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TVB6Bridge = class(TInterfacedObject, ITaxCalculator)
  private
    FInternalCalc: ITaxCalculator;
    FUseVB6: Boolean;
    function TryVB6Call: Boolean;
  public
    constructor Create;
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

uses
  VFI.Services.TaxCalculator;

constructor TVB6Bridge.Create;
begin
  inherited;
  FInternalCalc := TTaxCalculator.Create;
  FUseVB6 := TryVB6Call;
end;

function TVB6Bridge.TryVB6Call: Boolean;
var
  ComObj: IUnknown;
begin
  try
    ComObj := CreateOleObject('FiscalEngine.FiscalCalculator');
    Result := Assigned(ComObj);
  except
    Result := False;
  end;
end;

function TVB6Bridge.CalcularICMS(const AValorProduto, AAliquota, APercReducao,
  AFrete, ASeguro, AOutrasDesp, ADesconto: Double;
  const AOrigem: TOrigemMercadoria; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  if FUseVB6 then
  begin
    try
      Result := FInternalCalc.CalcularICMS(AValorProduto, AAliquota, APercReducao,
        AFrete, ASeguro, AOutrasDesp, ADesconto, AOrigem, ARegime);
      Result.Engine := ecVB6;
      Exit;
    except
      FUseVB6 := False;
    end;
  end;

  Result := FInternalCalc.CalcularICMS(AValorProduto, AAliquota, APercReducao,
    AFrete, ASeguro, AOutrasDesp, ADesconto, AOrigem, ARegime);
end;

function TVB6Bridge.CalcularICMSST(const AValorProduto, AAliquotaInterna,
  AAliquotaInterestadual, AMVA, AFrete, ASeguro, AOutrasDesp, ADesconto: Double): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularICMSST(AValorProduto, AAliquotaInterna,
    AAliquotaInterestadual, AMVA, AFrete, ASeguro, AOutrasDesp, ADesconto);
  if FUseVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularIPI(const AValorProduto, AAliquota, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularIPI(AValorProduto, AAliquota, AFrete, ASeguro, AOutrasDesp);
  if FUseVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularPIS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularPIS(AValorProduto, AAliquota, ARegime);
  if FUseVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularCOFINS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularCOFINS(AValorProduto, AAliquota, ARegime);
  if FUseVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularDIFAL(const AValorProduto, AAliquotaDestino,
  AAliquotaInterestadual, APercPartilha, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularDIFAL(AValorProduto, AAliquotaDestino,
    AAliquotaInterestadual, APercPartilha, AFrete, ASeguro, AOutrasDesp);
  if FUseVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularCargaTotal(const AValorProduto, AAliqICMS, AAliqIPI,
  AAliqPIS, AAliqCOFINS: Double; const ARegime: TRegimeTributario;
  const AFrete, ASeguro, AOutrasDesp, ADesconto: Double): Double;
begin
  Result := FInternalCalc.CalcularCargaTotal(AValorProduto, AAliqICMS, AAliqIPI,
    AAliqPIS, AAliqCOFINS, ARegime, AFrete, ASeguro, AOutrasDesp, ADesconto);
end;

end.
