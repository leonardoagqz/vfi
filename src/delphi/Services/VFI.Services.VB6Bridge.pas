unit VFI.Services.VB6Bridge;

interface

uses
  System.SysUtils,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TVB6Bridge = class(TInterfacedObject, ITaxCalculator)
  private
    FInternalCalc: ITaxCalculator;
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
end;

function TVB6Bridge.CalcularICMS(const AValorProduto, AAliquota, APercReducao,
  AFrete, ASeguro, AOutrasDesp, ADesconto: Double;
  const AOrigem: TOrigemMercadoria; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularICMS(AValorProduto, AAliquota, APercReducao,
    AFrete, ASeguro, AOutrasDesp, ADesconto, AOrigem, ARegime);
end;

function TVB6Bridge.CalcularICMSST(const AValorProduto, AAliquotaInterna,
  AAliquotaInterestadual, AMVA, AFrete, ASeguro, AOutrasDesp, ADesconto: Double): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularICMSST(AValorProduto, AAliquotaInterna,
    AAliquotaInterestadual, AMVA, AFrete, ASeguro, AOutrasDesp, ADesconto);
end;

function TVB6Bridge.CalcularIPI(const AValorProduto, AAliquota, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularIPI(AValorProduto, AAliquota, AFrete, ASeguro, AOutrasDesp);
end;

function TVB6Bridge.CalcularPIS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularPIS(AValorProduto, AAliquota, ARegime);
end;

function TVB6Bridge.CalcularCOFINS(const AValorProduto, AAliquota: Double; const ARegime: TRegimeTributario): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularCOFINS(AValorProduto, AAliquota, ARegime);
end;

function TVB6Bridge.CalcularDIFAL(const AValorProduto, AAliquotaDestino,
  AAliquotaInterestadual, APercPartilha, AFrete, ASeguro, AOutrasDesp: Double): TResultadoCalculo;
begin
  Result := FInternalCalc.CalcularDIFAL(AValorProduto, AAliquotaDestino,
    AAliquotaInterestadual, APercPartilha, AFrete, ASeguro, AOutrasDesp);
end;

function TVB6Bridge.CalcularCargaTotal(const AValorProduto, AAliqICMS, AAliqIPI,
  AAliqPIS, AAliqCOFINS: Double; const ARegime: TRegimeTributario;
  const AFrete, ASeguro, AOutrasDesp, ADesconto: Double): Double;
begin
  Result := FInternalCalc.CalcularCargaTotal(AValorProduto, AAliqICMS, AAliqIPI,
    AAliqPIS, AAliqCOFINS, ARegime, AFrete, ASeguro, AOutrasDesp, ADesconto);
end;

end.
