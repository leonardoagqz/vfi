unit uFiscalValidator;

interface

uses
  System.SysUtils, System.Classes, System.RegularExpressions, Data.DB;

type
  TValidationError = record
    Codigo: string;
    Campo: string;
    Mensagem: string;
  end;

  TValidationResult = record
    IsValid: Boolean;
    Errors: TArray<TValidationError>;
    function GetErrorsAsString: string;
  end;

  TFiscalValidator = class(TComponent)
  public
    function ValidarCNPJ(const CNPJ: string): Boolean;
    function ValidarChaveNFe(const Chave: string): Boolean;
    function ValidarNCM(const NCM: string): Boolean;
    function ValidarCFOP(const CFOP: string): Boolean;
    function ValidarDocumento(const DocumentId: Integer): TValidationResult;
  end;

implementation

function TValidationResult.GetErrorsAsString: string;
var
  Err: TValidationError;
begin
  Result := '';
  for Err in Errors do
    Result := Result + Format('[%s] %s: %s' + sLineBreak, [Err.Codigo, Err.Campo, Err.Mensagem]);
end;

function TFiscalValidator.ValidarCNPJ(const CNPJ: string): Boolean;
var
  Digits: string;
  i, Soma, Digito1, Digito2, Resto: Integer;
  Multiplicador1: array[0..11] of Integer = (5,4,3,2,9,8,7,6,5,4,3,2);
  Multiplicador2: array[0..12] of Integer = (6,5,4,3,2,9,8,7,6,5,4,3,2);
begin
  Result := False;
  Digits := TRegEx.Replace(CNPJ, '\D', '');
  if Length(Digits) <> 14 then Exit;

  Soma := 0;
  for i := 1 to 12 do
    Soma := Soma + (Ord(Digits[i]) - 48) * Multiplicador1[i-1];
  Resto := Soma mod 11;
  if Resto < 2 then Digito1 := 0 else Digito1 := 11 - Resto;

  Soma := 0;
  for i := 1 to 13 do
    Soma := Soma + (Ord(Digits[i]) - 48) * Multiplicador2[i-1];
  Resto := Soma mod 11;
  if Resto < 2 then Digito2 := 0 else Digito2 := 11 - Resto;

  Result := (Digito1 = Ord(Digits[13]) - 48) and (Digito2 = Ord(Digits[14]) - 48);
end;

function TFiscalValidator.ValidarChaveNFe(const Chave: string): Boolean;
var
  i, Soma, Peso, Digito: Integer;
  Limpa: string;
begin
  Limpa := TRegEx.Replace(Chave, '\D', '');
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

function TFiscalValidator.ValidarNCM(const NCM: string): Boolean;
var
  Limpa: string;
begin
  Limpa := Trim(NCM);
  Result := (Length(Limpa) = 8) and TRegEx.IsMatch(Limpa, '^\d{8}$');
end;

function TFiscalValidator.ValidarCFOP(const CFOP: string): Boolean;
var
  i: Integer;
begin
  Result := (Length(CFOP) = 4) and TryStrToInt(CFOP, i) and (i >= 1000) and (i <= 7999);
end;

function TFiscalValidator.ValidarDocumento(const DocumentId: Integer): TValidationResult;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.IsValid := True;

  { Em producao, carregaria dados do banco via DataModule
    e executaria as validacoes reais.
    Aqui demonstramos a estrutura de validacao. }

  SetLength(Result.Errors, 0);
end;

end.
