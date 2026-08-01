unit dmVFI;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, Vcl.Dialogs;

type
  TDataModuleVFI = class(TDataModule)
    Connection: TFDConnection;
    qryDocumentos: TFDQuery;
    qryItens: TFDQuery;
    qryImpostos: TFDQuery;
    dsDocumentos: TDataSource;
    dsItens: TDataSource;
    dsImpostos: TDataSource;
    qryDocumentosId: TIntegerField;
    qryDocumentosDocumentType: TStringField;
    qryDocumentosDocumentKey: TStringField;
    qryDocumentosDocumentNumber: TStringField;
    qryDocumentosIssueDate: TDateTimeField;
    qryDocumentosIssuerCNPJ: TStringField;
    qryDocumentosIssuerName: TStringField;
    qryDocumentosRecipientCNPJ: TStringField;
    qryDocumentosRecipientName: TStringField;
    qryDocumentosTotalValue: TFloatField;
    qryDocumentosStatus: TStringField;
    procedure DataModuleCreate(Sender: TObject);
  private
    function GetConnectionString: string;
  public
    procedure CarregarDocumentos;
    procedure ValidarDocumento(const DocumentId: Integer);
    procedure CalcularImpostos(const DocumentId: Integer);
    procedure AnalisarComIA(const DocumentId: Integer);
  end;

var
  DataModuleVFI: TDataModuleVFI;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  uFiscalValidator, uVB6Integration, uIAIntegration;

procedure TDataModuleVFI.DataModuleCreate(Sender: TObject);
begin
  Connection.ConnectionString := GetConnectionString;
  Connection.Connected := True;
end;

function TDataModuleVFI.GetConnectionString: string;
begin
  Result := 'Server=localhost;Database=VFI_DB;User_Name=vfi_app;Password=Vfi@2024#Dev;MARS=Yes;';
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
  Validator := TFiscalValidator.Create(Self);
  try
    qryItens.Close;
    qryItens.SQL.Text := 'SELECT * FROM DocumentItem WHERE DocumentId = :Id';
    qryItens.ParamByName('Id').AsInteger := DocumentId;
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
    qryItens.ParamByName('Id').AsInteger := DocumentId;
    qryItens.Open;

    qryItens.First;
    while not qryItens.Eof do
    begin
      ItemValor := qryItens.FieldByName('TotalValue').AsFloat;

      { Chamada a DLL VB6 via COM para calculo de ICMS }
      Engine.CalcularICMS(
        ItemValor,
        18.0,  { Aliquota ICMS 18% }
        0,     { Sem reducao }
        0,     { Frete }
        0,     { Seguro }
        0,     { Outras Despesas }
        0,     { Desconto }
        omNacional,
        trLucroReal
      );

      qryImpostos.Close;
      qryImpostos.SQL.Text :=
        'INSERT INTO TaxCalculation (DocumentId, ItemId, TaxType, TaxBase, TaxRate, TaxValue, CalculationEngine) ' +
        'VALUES (:DocId, :ItemId, :TaxType, :Base, :Rate, :Value, :Engine)';
      qryImpostos.ParamByName('DocId').AsInteger := DocumentId;
      qryImpostos.ParamByName('ItemId').AsInteger := qryItens.FieldByName('Id').AsInteger;
      qryImpostos.ParamByName('TaxType').AsString := 'ICMS';
      qryImpostos.ParamByName('Base').AsFloat := Engine.Resultado.BaseCalculo;
      qryImpostos.ParamByName('Rate').AsFloat := Engine.Resultado.Aliquota;
      qryImpostos.ParamByName('Value').AsFloat := Engine.Resultado.ValorImposto;
      qryImpostos.ParamByName('Engine').AsString := 'VB6';
      qryImpostos.ExecSQL;

      qryItens.Next;
    end;

    Connection.Commit;
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
  Analisador := TIAIntegration.Create(Self);
  try
    Log := Analisador.AnalisarDocumento(DocumentId);

    qryImpostos.Close;
    qryImpostos.SQL.Text :=
      'INSERT INTO AIAnalysisLog (DocumentId, Model, Prompt, Response, AnomaliesFound, ConfidenceScore) ' +
      'VALUES (:DocId, :Model, :Prompt, :Response, :Anomalies, :Score)';
    qryImpostos.ParamByName('DocId').AsInteger := DocumentId;
    qryImpostos.ParamByName('Model').AsString := Log.Model;
    qryImpostos.ParamByName('Prompt').AsString := Log.Prompt;
    qryImpostos.ParamByName('Response').AsString := Log.Response;
    qryImpostos.ParamByName('Anomalies').AsInteger := Log.AnomaliesFound;
    qryImpostos.ParamByName('Score').AsFloat := Log.ConfidenceScore;
    qryImpostos.ExecSQL;

    Connection.Commit;
    ShowMessage(Format('Analise IA concluida! %d anomalias encontradas.', [Log.AnomaliesFound]));
  finally
    Analisador.Free;
  end;
end;

end.
