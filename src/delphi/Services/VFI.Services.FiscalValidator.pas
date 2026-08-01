unit VFI.Services.FiscalValidator;

interface

uses
  System.SysUtils, System.RegularExpressions, System.Classes,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TFiscalValidator = class(TInterfacedObject, IFiscalValidator)
  public
    function ValidarCNPJ(const ACNPJ: string): Boolean;
    function ValidarChaveNFe(const AChave: string): Boolean;
    function ValidarNCM(const ANCM: string): Boolean;
    function ValidarCFOP(const ACFOP: string): Boolean;
    function ValidarDocumento(const ADocument: TFiscalDocument): TResultadoValidacao;
  end;

implementation

function TFiscalValidator.ValidarCNPJ(const ACNPJ: string): Boolean;
const
  MULT1: array[0..11] of Integer = (5,4,3,2,9,8,7,6,5,4,3,2);
  MULT2: array[0..12] of Integer = (6,5,4,3,2,9,8,7,6,5,4,3,2);
var
  Digits: string;
  i, Soma, Digito1, Digito2, Resto: Integer;
begin
  Result := False;
  Digits := TRegEx.Replace(ACNPJ, '\D', '');
  if Length(Digits) <> 14 then Exit;

  Soma := 0;
  for i := 1 to 12 do
    Soma := Soma + (Ord(Digits[i]) - 48) * MULT1[i - 1];
  Resto := Soma mod 11;
  if Resto < 2 then Digito1 := 0 else Digito1 := 11 - Resto;

  Soma := 0;
  for i := 1 to 13 do
    Soma := Soma + (Ord(Digits[i]) - 48) * MULT2[i - 1];
  Resto := Soma mod 11;
  if Resto < 2 then Digito2 := 0 else Digito2 := 11 - Resto;

  Result := (Digito1 = Ord(Digits[13]) - 48) and (Digito2 = Ord(Digits[14]) - 48);
end;

function TFiscalValidator.ValidarChaveNFe(const AChave: string): Boolean;
var
  i, Soma, Peso, Digito: Integer;
  Limpa: string;
begin
  Limpa := TRegEx.Replace(AChave, '\D', '');
  Result := Length(Limpa) = 44;
  if not Result then Exit;

  Soma := 0;
  Peso := 2;
  for i := 43 downto 1 do
  begin
    Soma := Soma + (Ord(Limpa[i]) - 48) * Peso;
    Inc(Peso);
    if Peso > 9 then Peso := 2;
  end;
  Digito := 11 - (Soma mod 11);
  if Digito >= 10 then Digito := 0;
  Result := Digito = (Ord(Limpa[44]) - 48);
end;

function TFiscalValidator.ValidarNCM(const ANCM: string): Boolean;
begin
  Result := (Length(Trim(ANCM)) = 8) and TRegEx.IsMatch(Trim(ANCM), '^\d{8}$');
end;

function TFiscalValidator.ValidarCFOP(const ACFOP: string): Boolean;
var
  i: Integer;
begin
  Result := (Length(ACFOP) = 4) and TryStrToInt(ACFOP, i) and (i >= 1000) and (i <= 7999);
end;

function TFiscalValidator.ValidarDocumento(const ADocument: TFiscalDocument): TResultadoValidacao;
var
  Item: TDocumentItem;
begin
  Result := TResultadoValidacao.Create;

  if (Length(ADocument.Chave) <> 44) or not TRegEx.IsMatch(ADocument.Chave, '^\d{44}$') then
    Result.Erros.Add('[E001] Chave: chave do documento fiscal deve ter 44 digitos');

  if not ValidarCNPJ(ADocument.CnpjEmitente) then
    Result.Erros.Add(Format('[E002] CnpjEmitente: CNPJ do emitente invalido (%s)', [ADocument.CnpjEmitente]));

  if not ValidarCNPJ(ADocument.CnpjDestinatario) then
    Result.Erros.Add(Format('[E003] CnpjDestinatario: CNPJ do destinatario invalido (%s)', [ADocument.CnpjDestinatario]));

  if ADocument.ValorTotal <= 0 then
    Result.Erros.Add('[E004] ValorTotal: valor total deve ser maior que zero');

  if ADocument.DataEmissao > Now + 1 then
    Result.Erros.Add('[E005] DataEmissao: data de emissao nao pode ser futura');

  for Item in ADocument.Itens do
  begin
    if not ValidarNCM(Item.NCM) then
      Result.Erros.Add(Format('[E010] NCM: NCM invalido para produto %s (%s)', [Item.CodigoProduto, Item.NCM]));

    if not ValidarCFOP(Item.CFOP) then
      Result.Erros.Add(Format('[E011] CFOP: CFOP invalido para produto %s (%s)', [Item.CodigoProduto, Item.CFOP]));

    if Item.Quantidade <= 0 then
      Result.Erros.Add(Format('[E012] Quantidade: quantidade invalida para produto %s', [Item.CodigoProduto]));
  end;

  Result.IsValid := Result.Erros.Count = 0;
end;

end.
