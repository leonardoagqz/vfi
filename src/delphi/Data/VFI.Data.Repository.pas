unit VFI.Data.Repository;

interface

uses
  System.SysUtils, System.Generics.Collections,
  Data.DB, Data.Win.ADODB,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TFiscalDocumentRepository = class(TInterfacedObject, IFiscalDocumentRepository)
  private
    function CriarQuery: TADOQuery;
    procedure PopularDocumento(const AQuery: TADOQuery; const ADoc: TFiscalDocument);
    procedure PopularItem(const AQuery: TADOQuery; const AItem: TDocumentItem);
    procedure PopularItens(const ADocId: Integer; const ADoc: TFiscalDocument);
    procedure PopularCalculos(const ADocId: Integer; const ADoc: TFiscalDocument);
  public
    function BuscarTodos: TObjectList<TFiscalDocument>;
    function BuscarPorId(const AId: Integer): TFiscalDocument;
    function BuscarPorFiltro(const ATipo: TTipoDocumento; const AStatus: string): TObjectList<TFiscalDocument>;
    procedure Inserir(const ADocument: TFiscalDocument);
    procedure AtualizarStatus(const AId: Integer; const AStatus: TStatusDocumento);
    procedure InserirCalculo(const ACalculo: TTaxCalculation);
    procedure InserirAnaliseIA(const ADocId: Integer; const AModelo, APrompt, AResposta: string;
      const AAnomalias: Integer; const AConfianca: Double);
  end;

implementation

uses
  VFI.Data.Connection;

function TFiscalDocumentRepository.CriarQuery: TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := TConnectionFactory.CriarConexao;
end;

procedure TFiscalDocumentRepository.PopularDocumento(const AQuery: TADOQuery; const ADoc: TFiscalDocument);
begin
  ADoc.Id := AQuery.FieldByName('Id').AsInteger;
  ADoc.Tipo := StrToTipoDocumento(AQuery.FieldByName('DocumentType').AsString);
  ADoc.Chave := AQuery.FieldByName('DocumentKey').AsString;
  ADoc.Numero := AQuery.FieldByName('DocumentNumber').AsString;
  ADoc.DataEmissao := AQuery.FieldByName('IssueDate').AsDateTime;
  ADoc.CnpjEmitente := AQuery.FieldByName('IssuerCNPJ').AsString;
  ADoc.NomeEmitente := AQuery.FieldByName('IssuerName').AsString;
  ADoc.CnpjDestinatario := AQuery.FieldByName('RecipientCNPJ').AsString;
  ADoc.NomeDestinatario := AQuery.FieldByName('RecipientName').AsString;
  ADoc.ValorTotal := AQuery.FieldByName('TotalValue').AsCurrency;
  ADoc.XmlContent := AQuery.FieldByName('XMLContent').AsString;
  ADoc.Status := stPendente;
end;

procedure TFiscalDocumentRepository.PopularItem(const AQuery: TADOQuery; const AItem: TDocumentItem);
begin
  AItem.Id := AQuery.FieldByName('Id').AsInteger;
  AItem.DocumentId := AQuery.FieldByName('DocumentId').AsInteger;
  AItem.CodigoProduto := AQuery.FieldByName('ProductCode').AsString;
  AItem.NomeProduto := AQuery.FieldByName('ProductName').AsString;
  AItem.NCM := AQuery.FieldByName('NCM').AsString;
  AItem.CFOP := AQuery.FieldByName('CFOP').AsString;
  AItem.Quantidade := AQuery.FieldByName('Quantity').AsFloat;
  AItem.ValorUnitario := AQuery.FieldByName('UnitValue').AsCurrency;
  AItem.ValorTotal := AQuery.FieldByName('TotalValue').AsCurrency;
  AItem.CST := AQuery.FieldByName('CST').AsString;
end;

procedure TFiscalDocumentRepository.PopularItens(const ADocId: Integer; const ADoc: TFiscalDocument);
var
  Qry: TADOQuery;
  Item: TDocumentItem;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM DocumentItem WHERE DocumentId = :Id';
    Qry.Parameters.ParamByName('Id').Value := ADocId;
    Qry.Open;
    while not Qry.Eof do
    begin
      Item := TDocumentItem.Create;
      PopularItem(Qry, Item);
      ADoc.Itens.Add(Item);
      Qry.Next;
    end;
  finally
    Qry.Connection.Free;
    Qry.Free;
  end;
end;

procedure TFiscalDocumentRepository.PopularCalculos(const ADocId: Integer; const ADoc: TFiscalDocument);
var
  Qry: TADOQuery;
  Calc: TTaxCalculation;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM TaxCalculation WHERE DocumentId = :Id';
    Qry.Parameters.ParamByName('Id').Value := ADocId;
    Qry.Open;
    while not Qry.Eof do
    begin
      Calc := TTaxCalculation.Create;
      Calc.Id := Qry.FieldByName('Id').AsInteger;
      Calc.DocumentId := ADocId;
      Calc.ItemId := Qry.FieldByName('ItemId').AsInteger;
      Calc.TipoImposto := TTipoImposto(Qry.FieldByName('TaxType').AsInteger);
      Calc.BaseCalculo := Qry.FieldByName('TaxBase').AsCurrency;
      Calc.Aliquota := Qry.FieldByName('TaxRate').AsFloat;
      Calc.ValorImposto := Qry.FieldByName('TaxValue').AsCurrency;
      Calc.Engine := TEngineCalculo(Qry.FieldByName('CalculationEngine').AsInteger);
      ADoc.Calculos.Add(Calc);
      Qry.Next;
    end;
  finally
    Qry.Connection.Free;
    Qry.Free;
  end;
end;

function TFiscalDocumentRepository.BuscarTodos: TObjectList<TFiscalDocument>;
var
  Qry: TADOQuery;
  Doc: TFiscalDocument;
begin
  Result := TObjectList<TFiscalDocument>.Create(True);
  Qry := CriarQuery;
  try
    Qry.SQL.Text :=
      'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, ' +
      'XMLContent, Status FROM FiscalDocument ORDER BY IssueDate DESC';
    Qry.Open;
    while not Qry.Eof do
    begin
      Doc := TFiscalDocument.Create;
      PopularDocumento(Qry, Doc);
      PopularItens(Doc.Id, Doc);
      PopularCalculos(Doc.Id, Doc);
      Result.Add(Doc);
      Qry.Next;
    end;
  finally
    Qry.Connection.Free;
    Qry.Free;
  end;
end;

function TFiscalDocumentRepository.BuscarPorId(const AId: Integer): TFiscalDocument;
var
  Qry: TADOQuery;
begin
  Result := nil;
  Qry := CriarQuery;
  try
    Qry.SQL.Text :=
      'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, ' +
      'XMLContent, Status FROM FiscalDocument WHERE Id = :Id';
    Qry.Parameters.ParamByName('Id').Value := AId;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      Result := TFiscalDocument.Create;
      PopularDocumento(Qry, Result);
      PopularItens(Result.Id, Result);
      PopularCalculos(Result.Id, Result);
    end;
  finally
    Qry.Connection.Free;
    Qry.Free;
  end;
end;

function TFiscalDocumentRepository.BuscarPorFiltro(const ATipo: TTipoDocumento;
  const AStatus: string): TObjectList<TFiscalDocument>;
begin
  Result := BuscarTodos;
end;

procedure TFiscalDocumentRepository.Inserir(const ADocument: TFiscalDocument);
var
  Qry: TADOQuery;
  DocId: Integer;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text :=
      'INSERT INTO FiscalDocument (DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status) ' +
      'VALUES (:Tipo, :Chave, :Numero, :Data, :CNPJE, :NomeE, :CNPJD, :NomeD, :Valor, :XML, :Status); ' +
      'SELECT SCOPE_IDENTITY()';
    Qry.Parameters.ParamByName('Tipo').Value := TipoDocumentoToStr(ADocument.Tipo);
    Qry.Parameters.ParamByName('Chave').Value := ADocument.Chave;
    Qry.Parameters.ParamByName('Numero').Value := ADocument.Numero;
    Qry.Parameters.ParamByName('Data').Value := ADocument.DataEmissao;
    Qry.Parameters.ParamByName('CNPJE').Value := ADocument.CnpjEmitente;
    Qry.Parameters.ParamByName('NomeE').Value := ADocument.NomeEmitente;
    Qry.Parameters.ParamByName('CNPJD').Value := ADocument.CnpjDestinatario;
    Qry.Parameters.ParamByName('NomeD').Value := ADocument.NomeDestinatario;
    Qry.Parameters.ParamByName('Valor').Value := ADocument.ValorTotal;
    Qry.Parameters.ParamByName('XML').Value := ADocument.XmlContent;
    Qry.Parameters.ParamByName('Status').Value := StatusToStr(ADocument.Status);
    Qry.Open;
    DocId := Qry.Fields[0].AsInteger;
    ADocument.Id := DocId;
  finally
    Qry.Connection.Free;
    Qry.Free;
  end;
end;

procedure TFiscalDocumentRepository.AtualizarStatus(const AId: Integer; const AStatus: TStatusDocumento);
var
  Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'UPDATE FiscalDocument SET Status = :Status, UpdatedAt = GETDATE() WHERE Id = :Id';
    Qry.Parameters.ParamByName('Status').Value := StatusToStr(AStatus);
    Qry.Parameters.ParamByName('Id').Value := AId;
    Qry.ExecSQL;
  finally
    Qry.Connection.Free;
    Qry.Free;
  end;
end;

procedure TFiscalDocumentRepository.InserirCalculo(const ACalculo: TTaxCalculation);
var
  Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text :=
      'INSERT INTO TaxCalculation (DocumentId, ItemId, TaxType, TaxBase, TaxRate, TaxValue, CalculationEngine) ' +
      'VALUES (:DocId, :ItemId, :TaxType, :Base, :Rate, :Value, :Engine)';
    Qry.Parameters.ParamByName('DocId').Value := ACalculo.DocumentId;
    Qry.Parameters.ParamByName('ItemId').Value := ACalculo.ItemId;
    Qry.Parameters.ParamByName('TaxType').Value := ImpostoToStr(ACalculo.TipoImposto);
    Qry.Parameters.ParamByName('Base').Value := ACalculo.BaseCalculo;
    Qry.Parameters.ParamByName('Rate').Value := ACalculo.Aliquota;
    Qry.Parameters.ParamByName('Value').Value := ACalculo.ValorImposto;
    Qry.Parameters.ParamByName('Engine').Value := 'VB6';
    Qry.ExecSQL;
  finally
    Qry.Connection.Free;
    Qry.Free;
  end;
end;

procedure TFiscalDocumentRepository.InserirAnaliseIA(const ADocId: Integer;
  const AModelo, APrompt, AResposta: string; const AAnomalias: Integer; const AConfianca: Double);
var
  Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text :=
      'INSERT INTO AIAnalysisLog (DocumentId, Model, Prompt, Response, AnomaliesFound, ConfidenceScore) ' +
      'VALUES (:DocId, :Model, :Prompt, :Response, :Anomalies, :Score)';
    Qry.Parameters.ParamByName('DocId').Value := ADocId;
    Qry.Parameters.ParamByName('Model').Value := AModelo;
    Qry.Parameters.ParamByName('Prompt').Value := APrompt;
    Qry.Parameters.ParamByName('Response').Value := AResposta;
    Qry.Parameters.ParamByName('Anomalies').Value := AAnomalias;
    Qry.Parameters.ParamByName('Score').Value := AConfianca;
    Qry.ExecSQL;
  finally
    Qry.Connection.Free;
    Qry.Free;
  end;
end;

end.
