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

function QuotedStrSafe(const S: string): string;
begin
  Result := '''' + StringReplace(S, '''', '''''', [rfReplaceAll]) + '''';
end;

function FloatToSql(const V: Double): string;
begin
  Result := StringReplace(FloatToStr(V), ',', '.', []);
end;

function CurrToSql(const V: Currency): string;
begin
  Result := StringReplace(CurrToStr(V), ',', '.', []);
end;

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
    Qry.SQL.Text := 'SELECT * FROM DocumentItem WHERE DocumentId = ' + IntToStr(ADocId);
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
    Qry.SQL.Text := 'SELECT * FROM TaxCalculation WHERE DocumentId = ' + IntToStr(ADocId);
    Qry.Open;
    while not Qry.Eof do
    begin
      Calc := TTaxCalculation.Create;
      Calc.Id := Qry.FieldByName('Id').AsInteger;
      Calc.DocumentId := ADocId;
      Calc.ItemId := Qry.FieldByName('ItemId').AsInteger;
      Calc.TipoImposto := StrToImposto(Qry.FieldByName('TaxType').AsString);
      Calc.BaseCalculo := Qry.FieldByName('TaxBase').AsCurrency;
      Calc.Aliquota := Qry.FieldByName('TaxRate').AsFloat;
      Calc.ValorImposto := Qry.FieldByName('TaxValue').AsCurrency;
      Calc.Engine := ecInternal;
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
      'XMLContent, Status FROM FiscalDocument WHERE Id = ' + IntToStr(AId);
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
var
  Qry: TADOQuery;
  Doc: TFiscalDocument;
  SQL, TipoStr: string;
begin
  Result := TObjectList<TFiscalDocument>.Create(True);
  TipoStr := TipoDocumentoToStr(ATipo);
  SQL :=
    'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
    'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, ' +
    'XMLContent, Status FROM FiscalDocument WHERE 1=1';

  if ATipo <> tdNFe then
    SQL := SQL + ' AND DocumentType = ' + QuotedStrSafe(TipoStr);
  if AStatus <> '' then
    SQL := SQL + ' AND Status = ' + QuotedStrSafe(AStatus);
  SQL := SQL + ' ORDER BY IssueDate DESC';

  Qry := CriarQuery;
  try
    Qry.SQL.Text := SQL;
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

procedure TFiscalDocumentRepository.Inserir(const ADocument: TFiscalDocument);
var
  Qry: TADOQuery;
  SQL: string;
begin
  Qry := CriarQuery;
  try
    SQL := Format(
      'INSERT INTO FiscalDocument (DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status) ' +
      'VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s); SELECT SCOPE_IDENTITY()',
      [QuotedStrSafe(TipoDocumentoToStr(ADocument.Tipo)),
       QuotedStrSafe(ADocument.Chave),
       QuotedStrSafe(ADocument.Numero),
       QuotedStrSafe(FormatDateTime('yyyy-mm-dd hh:nn:ss', ADocument.DataEmissao)),
       QuotedStrSafe(ADocument.CnpjEmitente),
       QuotedStrSafe(ADocument.NomeEmitente),
       QuotedStrSafe(ADocument.CnpjDestinatario),
       QuotedStrSafe(ADocument.NomeDestinatario),
       CurrToSql(ADocument.ValorTotal),
       QuotedStrSafe(ADocument.XmlContent),
       QuotedStrSafe(StatusToStr(ADocument.Status))]);

    Qry.SQL.Text := SQL;
    Qry.Open;
    ADocument.Id := Qry.Fields[0].AsInteger;
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
    Qry.SQL.Text := Format(
      'UPDATE FiscalDocument SET Status = %s, UpdatedAt = GETDATE() WHERE Id = %d',
      [QuotedStrSafe(StatusToStr(AStatus)), AId]);
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
    Qry.SQL.Text := Format(
      'INSERT INTO TaxCalculation (DocumentId, ItemId, TaxType, TaxBase, TaxRate, TaxValue, CalculationEngine) ' +
      'VALUES (%d,%d,%s,%s,%s,%s,%s)',
      [ACalculo.DocumentId,
       ACalculo.ItemId,
       QuotedStrSafe(ImpostoToStr(ACalculo.TipoImposto)),
       CurrToSql(ACalculo.BaseCalculo),
       FloatToSql(ACalculo.Aliquota),
       CurrToSql(ACalculo.ValorImposto),
       QuotedStrSafe('Internal')]);
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
    Qry.SQL.Text := Format(
      'INSERT INTO AIAnalysisLog (DocumentId, Model, Prompt, Response, AnomaliesFound, ConfidenceScore) ' +
      'VALUES (%d,%s,%s,%s,%d,%s)',
      [ADocId,
       QuotedStrSafe(AModelo),
       QuotedStrSafe(APrompt),
       QuotedStrSafe(AResposta),
       AAnomalias,
       FloatToSql(AConfianca)]);
    Qry.ExecSQL;
  finally
    Qry.Connection.Free;
    Qry.Free;
  end;
end;

end.
