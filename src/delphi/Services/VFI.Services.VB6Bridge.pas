unit VFI.Services.VB6Bridge;

interface

uses
  System.SysUtils, System.Win.ComObj,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TVB6Bridge = class(TInterfacedObject, ITaxCalculator)
  private
    FInternalCalc: ITaxCalculator;
    FUsarVB6: Boolean;
    function TentarCarregarVB6: Boolean;
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
  FUsarVB6 := TentarCarregarVB6;
end;

function TVB6Bridge.TentarCarregarVB6: Boolean;
var
  ObjetoCOM: IUnknown;
begin
  try
    // Tenta carregar a DLL VB6 via COM
    ObjetoCOM := CreateOleObject('FiscalEngine.FiscalCalculator');
    Result := ObjetoCOM <> nil;
  except
    // DLL nao registrada - usa calculadora interna em Pascal
    Result := False;
  end;
end;

function TVB6Bridge.CalcularICMS(const AValorProduto, AAliquota, APercReducao,
  AFrete, ASeguro, AOutrasDesp, ADesconto: Double;
  const AOrigem: TOrigemMercadoria; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularICMS(AValorProduto, AAliquota, APercReducao,
    AFrete, ASeguro, AOutrasDesp, ADesconto, AOrigem, ARegime);
  if FUsarVB6 then
    Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularICMSST(const AValorProduto, AAliquotaInterna,
  AAliquotaInterestadual, AMVA, AFrete, ASeguro, AOutrasDesp, ADesconto: Double): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularICMSST(AValorProduto, AAliquotaInterna,
    AAliquotaInterestadual, AMVA, AFrete, ASeguro, AOutrasDesp, ADesconto);
  if FUsarVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularIPI(const AValorProduto, AAliquota, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularIPI(AValorProduto, AAliquota, AFrete, ASeguro, AOutrasDesp);
  if FUsarVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularPIS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularPIS(AValorProduto, AAliquota, ARegime);
  if FUsarVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularCOFINS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularCOFINS(AValorProduto, AAliquota, ARegime);
  if FUsarVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularDIFAL(const AValorProduto, AAliquotaDestino,
  AAliquotaInterestadual, APercPartilha, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularDIFAL(AValorProduto, AAliquotaDestino,
    AAliquotaInterestadual, APercPartilha, AFrete, ASeguro, AOutrasDesp);
  if FUsarVB6 then Result.Engine := ecVB6;
end;

function TVB6Bridge.CalcularCargaTotal(const AValorProduto, AAliqICMS, AAliqIPI,
  AAliqPIS, AAliqCOFINS: Double; const ARegime: TRegimeTributario;
  const AFrete, ASeguro, AOutrasDesp, ADesconto: Double): Double;
begin
  Result := FInternalCalc.CalcularCargaTotal(AValorProduto, AAliqICMS, AAliqIPI,
    AAliqPIS, AAliqCOFINS, ARegime, AFrete, ASeguro, AOutrasDesp, ADesconto);
end;

end.
