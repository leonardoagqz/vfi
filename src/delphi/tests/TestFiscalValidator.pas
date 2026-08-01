unit TestFiscalValidator;

interface

uses
  TestFramework, System.SysUtils, uFiscalValidator;

type
  TestTFiscalValidator = class(TTestCase)
  private
    FValidator: TFiscalValidator;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestValidarCNPJ_Valido;
    procedure TestValidarCNPJ_Invalido;
    procedure TestValidarCNPJ_TamanhoErrado;
    procedure TestValidarNCM_Valido;
    procedure TestValidarNCM_Invalido;
    procedure TestValidarCFOP_Valido;
    procedure TestValidarCFOP_Invalido;
    procedure TestValidarChaveNFe_44Digitos;
    procedure TestValidarChaveNFe_TamanhoErrado;
  end;

implementation

procedure TestTFiscalValidator.SetUp;
begin
  inherited;
  FValidator := TFiscalValidator.Create(nil);
end;

procedure TestTFiscalValidator.TearDown;
begin
  FValidator.Free;
  inherited;
end;

procedure TestTFiscalValidator.TestValidarCNPJ_Valido;
begin
  CheckTrue(FValidator.ValidarCNPJ('11222333000181'), 'CNPJ valido deve retornar True');
end;

procedure TestTFiscalValidator.TestValidarCNPJ_Invalido;
begin
  CheckFalse(FValidator.ValidarCNPJ('11222333000182'), 'CNPJ com digito errado deve retornar False');
  CheckFalse(FValidator.ValidarCNPJ('00000000000000'), 'CNPJ com todos zeros deve retornar False');
end;

procedure TestTFiscalValidator.TestValidarCNPJ_TamanhoErrado;
begin
  CheckFalse(FValidator.ValidarCNPJ('12345'), 'CNPJ curto deve retornar False');
  CheckFalse(FValidator.ValidarCNPJ(''), 'CNPJ vazio deve retornar False');
end;

procedure TestTFiscalValidator.TestValidarNCM_Valido;
begin
  CheckTrue(FValidator.ValidarNCM('84714900'), 'NCM valido deve retornar True');
  CheckTrue(FValidator.ValidarNCM('48201000'), 'NCM valido deve retornar True');
end;

procedure TestTFiscalValidator.TestValidarNCM_Invalido;
begin
  CheckFalse(FValidator.ValidarNCM('12345'), 'NCM com 5 digitos deve retornar False');
  CheckFalse(FValidator.ValidarNCM('ABCDEFGH'), 'NCM com letras deve retornar False');
end;

procedure TestTFiscalValidator.TestValidarCFOP_Valido;
begin
  CheckTrue(FValidator.ValidarCFOP('5101'), 'CFOP de venda interestadual deve ser valido');
  CheckTrue(FValidator.ValidarCFOP('6102'), 'CFOP de venda interestadual deve ser valido');
end;

procedure TestTFiscalValidator.TestValidarCFOP_Invalido;
begin
  CheckFalse(FValidator.ValidarCFOP('9999'), 'CFOP fora da faixa deve retornar False');
  CheckFalse(FValidator.ValidarCFOP('ABCD'), 'CFOP nao numerico deve retornar False');
end;

procedure TestTFiscalValidator.TestValidarChaveNFe_44Digitos;
begin
  CheckTrue(FValidator.ValidarChaveNFe('35240112345678901234567890123456789012345678'),
    'Chave NFe com 44 digitos deve ser valida');
end;

procedure TestTFiscalValidator.TestValidarChaveNFe_TamanhoErrado;
begin
  CheckFalse(FValidator.ValidarChaveNFe('12345'), 'Chave NFe curta deve retornar False');
end;

initialization
  RegisterTest(TestTFiscalValidator.Suite);

end.
