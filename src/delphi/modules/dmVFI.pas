unit dmVFI;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, Vcl.Dialogs;

type
  TDataModuleVFI = class(TDataModule)
    Connection: TADOConnection;
    qryDocumentos: TADOQuery;
    qryItens: TADOQuery;
    qryImpostos: TADOQuery;
    dsDocumentos: TDataSource;
    dsItens: TDataSource;
    dsImpostos: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  public
    procedure CarregarDocumentos;
    procedure ValidarDocumento(const DocumentId: Integer);
    procedure CalcularImpostos(const DocumentId: Integer);
    procedure AnalisarComIA(const DocumentId: Integer);
  end;

var
  DataModuleVFI: TDataModuleVFI;

implementation

{$R *.dfm}

uses
  uFiscalValidator, uVB6Integration, uIAIntegration;

procedure TDataModuleVFI.DataModuleCreate(Sender: TObject);
begin
  Connection.ConnectionString :=
    'Provider=MSOLEDBSQL;' +
    'Server=localhost;' +
    'Database=VFI_DB;' +
    'User ID=vfi_app;' +
    'Password=Vfi@2024#Dev;' +
    'Persist Security Info=False;';
  Connection.LoginPrompt := False;
  Connection.Connected := True;
end;

procedure TDataModuleVFI.CarregarDocumentos;
begin
  qryDocumentos.Close;
  qryDocumentos.SQL.Text :=
    'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
    'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, Status ' +
    'FROM FiscalDocument ORDER BY IssueDate DESC';
  qryDocumentos.Open;
end;

procedure TDataModuleVFI.ValidarDocumento(const DocumentId: Integer);
var
  Validator: TFiscalValidator;
  Resultado: TValidationResult;
begin
  Validator := TFiscalValidator.Create(nil);
  try
    qryItens.Close;
    qryItens.SQL.Text := 'SELECT * FROM DocumentItem WHERE DocumentId = :Id';
    qryItens.Parameters.ParamByName('Id').Value := DocumentId;
    qryItens.Open;

    Resultado := Validator.ValidarDocumento(DocumentId);

    if Resultado.IsValid then
      ShowMessage('Documento valido!')
    else
      ShowMessage('Documento com inconsistências: ' + Resultado.GetErrorsAsString);
  finally
    Validator.Free;
  end;
end;

procedure TDataModuleVFI.CalcularImpostos(const DocumentId: Integer);
var
  Engine: TVB6FiscalEngine;
  ItemValor: Double;
begin
  Engine := TVB6FiscalEngine.Create;
  try
    qryItens.Close;
    qryItens.SQL.Text := 'SELECT * FROM DocumentItem WHERE DocumentId = :Id';
    qryItens.Parameters.ParamByName('Id').Value := DocumentId;
    qryItens.Open;

    qryItens.First;
    while not qryItens.Eof do
    begin
      ItemValor := qryItens.FieldByName('TotalValue').AsFloat;

      Engine.CalcularICMS(
        ItemValor,
        18.0,
        0,
        0,
        0,
        0,
        0,
        omNacional,
        trLucroReal
      );

      qryImpostos.Close;
      qryImpostos.SQL.Text :=
        'INSERT INTO TaxCalculation (DocumentId, ItemId, TaxType, TaxBase, TaxRate, TaxValue, CalculationEngine) ' +
        'VALUES (:DocId, :ItemId, :TaxType, :Base, :Rate, :Value, :Engine)';
      qryImpostos.Parameters.ParamByName('DocId').Value := DocumentId;
      qryImpostos.Parameters.ParamByName('ItemId').Value := qryItens.FieldByName('Id').AsInteger;
      qryImpostos.Parameters.ParamByName('TaxType').Value := 'ICMS';
      qryImpostos.Parameters.ParamByName('Base').Value := Engine.Resultado.BaseCalculo;
      qryImpostos.Parameters.ParamByName('Rate').Value := Engine.Resultado.Aliquota;
      qryImpostos.Parameters.ParamByName('Value').Value := Engine.Resultado.ValorImposto;
      qryImpostos.Parameters.ParamByName('Engine').Value := 'VB6';
      qryImpostos.ExecSQL;

      qryItens.Next;
    end;

    ShowMessage('Impostos calculados com sucesso via DLL VB6!');
  finally
    Engine.Free;
  end;
end;

procedure TDataModuleVFI.AnalisarComIA(const DocumentId: Integer);
var
  Analisador: TIAIntegration;
  Log: TAIResult;
begin
  Analisador := TIAIntegration.Create(nil);
  try
    Log := Analisador.AnalisarDocumento(DocumentId);

    qryImpostos.Close;
    qryImpostos.SQL.Text :=
      'INSERT INTO AIAnalysisLog (DocumentId, Model, Prompt, Response, AnomaliesFound, ConfidenceScore) ' +
      'VALUES (:DocId, :Model, :Prompt, :Response, :Anomalies, :Score)';
    qryImpostos.Parameters.ParamByName('DocId').Value := DocumentId;
    qryImpostos.Parameters.ParamByName('Model').Value := Log.Model;
    qryImpostos.Parameters.ParamByName('Prompt').Value := Log.Prompt;
    qryImpostos.Parameters.ParamByName('Response').Value := Log.Response;
    qryImpostos.Parameters.ParamByName('Anomalies').Value := Log.AnomaliesFound;
    qryImpostos.Parameters.ParamByName('Score').Value := Log.ConfidenceScore;
    qryImpostos.ExecSQL;

    ShowMessage(Format('Analise IA concluida! %d anomalias encontradas.', [Log.AnomaliesFound]));
  finally
    Analisador.Free;
  end;
end;

end.
