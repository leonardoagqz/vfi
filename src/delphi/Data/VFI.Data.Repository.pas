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
    function InserirItem(const AItem: TDocumentItem): Integer;
    procedure SetParam(const AQuery: TADOQuery; const AName: string; AType: TFieldType; const AValue: Variant);
  public
    function BuscarTodos: TObjectList<TFiscalDocument>;
    function BuscarPorId(const AId: Integer): TFiscalDocument;
    function BuscarPorFiltro(const ATipo: TTipoDocumento; const AStatus: string): TObjectList<TFiscalDocument>;
    procedure Inserir(const ADocument: TFiscalDocument);
    procedure AtualizarStatus(const AId: Integer; const AStatus: TStatusDocumento);
    function ExisteChave(const AChave: string): Boolean;
    procedure Excluir(const AId: Integer);
    procedure InserirCalculo(const ACalculo: TTaxCalculation);
    procedure InserirAnaliseIA(const ADocId: Integer; const AModelo, APrompt, AResposta: string;
      const AAnomalias: Integer; const AConfianca: Double);
  end;

implementation

uses
  VFI.Data.Connection;

procedure TFiscalDocumentRepository.SetParam(const AQuery: TADOQuery; const AName: string;
  AType: TFieldType; const AValue: Variant);
begin
  with AQuery.Parameters.AddParameter do
  begin
    Name := AName;
    DataType := AType;
    Direction := pdInput;
    Value := AValue;
  end;
end;

function TFiscalDocumentRepository.CriarQuery: TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := TConnectionFactory.CriarConexao;
  Result.ParamCheck := False;
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
var Qry: TADOQuery; Item: TDocumentItem;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM DocumentItem WHERE DocumentId = :id';
    SetParam(Qry, 'id', ftInteger, ADocId);
    Qry.Open;
    while not Qry.Eof do begin
      Item := TDocumentItem.Create; PopularItem(Qry, Item);
      ADoc.Itens.Add(Item); Qry.Next;
    end;
  finally Qry.Connection.Free; Qry.Free; end;
end;

procedure TFiscalDocumentRepository.PopularCalculos(const ADocId: Integer; const ADoc: TFiscalDocument);
var Qry: TADOQuery; Calc: TTaxCalculation;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM TaxCalculation WHERE DocumentId = :id';
    SetParam(Qry, 'id', ftInteger, ADocId);
    Qry.Open;
    while not Qry.Eof do begin
      Calc := TTaxCalculation.Create;
      Calc.Id := Qry.FieldByName('Id').AsInteger; Calc.DocumentId := ADocId;
      Calc.ItemId := Qry.FieldByName('ItemId').AsInteger;
      Calc.TipoImposto := StrToImposto(Qry.FieldByName('TaxType').AsString);
      Calc.BaseCalculo := Qry.FieldByName('TaxBase').AsCurrency;
      Calc.Aliquota := Qry.FieldByName('TaxRate').AsFloat;
      Calc.ValorImposto := Qry.FieldByName('TaxValue').AsCurrency;
      Calc.Engine := ecInternal; ADoc.Calculos.Add(Calc); Qry.Next;
    end;
  finally Qry.Connection.Free; Qry.Free; end;
end;

function TFiscalDocumentRepository.BuscarTodos: TObjectList<TFiscalDocument>;
var Qry: TADOQuery; Doc: TFiscalDocument;
begin
  Result := TObjectList<TFiscalDocument>.Create(True); Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status ' +
      'FROM FiscalDocument ORDER BY IssueDate DESC';
    Qry.Open;
    while not Qry.Eof do begin
      Doc := TFiscalDocument.Create; PopularDocumento(Qry, Doc);
      PopularItens(Doc.Id, Doc); PopularCalculos(Doc.Id, Doc); Result.Add(Doc); Qry.Next;
    end;
  finally Qry.Connection.Free; Qry.Free; end;
end;

function TFiscalDocumentRepository.BuscarPorId(const AId: Integer): TFiscalDocument;
var Qry: TADOQuery;
begin
  Result := nil; Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status ' +
      'FROM FiscalDocument WHERE Id = :id';
    SetParam(Qry, 'id', ftInteger, AId);
    Qry.Open;
    if not Qry.IsEmpty then begin
      Result := TFiscalDocument.Create; PopularDocumento(Qry, Result);
      PopularItens(Result.Id, Result); PopularCalculos(Result.Id, Result);
    end;
  finally Qry.Connection.Free; Qry.Free; end;
end;

function TFiscalDocumentRepository.BuscarPorFiltro(const ATipo: TTipoDocumento;
  const AStatus: string): TObjectList<TFiscalDocument>;
begin
  Result := BuscarTodos;
end;

function TFiscalDocumentRepository.InserirItem(const AItem: TDocumentItem): Integer;
var Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'INSERT INTO DocumentItem (DocumentId, ProductCode, ProductName, NCM, CFOP, ' +
      'Quantity, UnitValue, TotalValue, CST) VALUES (:docid,:cod,:nome,:ncm,:cfop,:qtd,:vu,:vt,:cst); SELECT SCOPE_IDENTITY()';
    SetParam(Qry,'docid',ftInteger,AItem.DocumentId); SetParam(Qry,'cod',ftString,AItem.CodigoProduto);
    SetParam(Qry,'nome',ftString,AItem.NomeProduto); SetParam(Qry,'ncm',ftString,AItem.NCM);
    SetParam(Qry,'cfop',ftString,AItem.CFOP); SetParam(Qry,'qtd',ftFloat,AItem.Quantidade);
    SetParam(Qry,'vu',ftCurrency,AItem.ValorUnitario); SetParam(Qry,'vt',ftCurrency,AItem.ValorTotal);
    SetParam(Qry,'cst',ftString,AItem.CST);
    Qry.Open; Result := Qry.Fields[0].AsInteger;
  finally Qry.Connection.Free; Qry.Free; end;
end;

procedure TFiscalDocumentRepository.Inserir(const ADocument: TFiscalDocument);
var Qry: TADOQuery; Item: TDocumentItem;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'INSERT INTO FiscalDocument (DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status) ' +
      'VALUES (:tp,:ch,:num,:dt,:ce,:ne,:cd,:nd,:vl,:xml,:st); SELECT SCOPE_IDENTITY()';
    SetParam(Qry,'tp',ftString,TipoDocumentoToStr(ADocument.Tipo)); SetParam(Qry,'ch',ftString,ADocument.Chave);
    SetParam(Qry,'num',ftString,ADocument.Numero); SetParam(Qry,'dt',ftDateTime,ADocument.DataEmissao);
    SetParam(Qry,'ce',ftString,ADocument.CnpjEmitente); SetParam(Qry,'ne',ftString,ADocument.NomeEmitente);
    SetParam(Qry,'cd',ftString,ADocument.CnpjDestinatario); SetParam(Qry,'nd',ftString,ADocument.NomeDestinatario);
    SetParam(Qry,'vl',ftCurrency,ADocument.ValorTotal); SetParam(Qry,'xml',ftString,ADocument.XmlContent);
    SetParam(Qry,'st',ftString,StatusToStr(ADocument.Status));
    Qry.Open; ADocument.Id := Qry.Fields[0].AsInteger;
  finally Qry.Connection.Free; Qry.Free; end;
  for Item in ADocument.Itens do begin Item.DocumentId := ADocument.Id; Item.Id := InserirItem(Item); end;
end;

procedure TFiscalDocumentRepository.AtualizarStatus(const AId: Integer; const AStatus: TStatusDocumento);
var Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'UPDATE FiscalDocument SET Status = :st, UpdatedAt = GETDATE() WHERE Id = :id';
    SetParam(Qry,'st',ftString,StatusToStr(AStatus)); SetParam(Qry,'id',ftInteger,AId);
    Qry.ExecSQL;
  finally Qry.Connection.Free; Qry.Free; end;
end;

function TFiscalDocumentRepository.ExisteChave(const AChave: string): Boolean;
var Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT COUNT(*) FROM FiscalDocument WHERE DocumentKey = :ch';
    SetParam(Qry,'ch',ftString,AChave); Qry.Open;
    Result := Qry.Fields[0].AsInteger > 0;
  finally Qry.Connection.Free; Qry.Free; end;
end;

procedure TFiscalDocumentRepository.Excluir(const AId: Integer);
var Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'DELETE FROM AIAnalysisLog WHERE DocumentId = :id'; SetParam(Qry,'id',ftInteger,AId); Qry.ExecSQL;
    Qry.SQL.Text := 'DELETE FROM TaxCalculation WHERE DocumentId = :id'; SetParam(Qry,'id',ftInteger,AId); Qry.ExecSQL;
    Qry.SQL.Text := 'DELETE FROM DocumentItem WHERE DocumentId = :id'; SetParam(Qry,'id',ftInteger,AId); Qry.ExecSQL;
    Qry.SQL.Text := 'DELETE FROM FiscalDocument WHERE Id = :id'; SetParam(Qry,'id',ftInteger,AId); Qry.ExecSQL;
  finally Qry.Connection.Free; Qry.Free; end;
end;

procedure TFiscalDocumentRepository.InserirCalculo(const ACalculo: TTaxCalculation);
var Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'INSERT INTO TaxCalculation (DocumentId, ItemId, TaxType, TaxBase, TaxRate, TaxValue, CalculationEngine) ' +
      'VALUES (:di,:ii,:tt,:bc,:rt,:vl,:eg)';
    SetParam(Qry,'di',ftInteger,ACalculo.DocumentId); SetParam(Qry,'ii',ftInteger,ACalculo.ItemId);
    SetParam(Qry,'tt',ftString,ImpostoToStr(ACalculo.TipoImposto)); SetParam(Qry,'bc',ftCurrency,ACalculo.BaseCalculo);
    SetParam(Qry,'rt',ftFloat,ACalculo.Aliquota); SetParam(Qry,'vl',ftCurrency,ACalculo.ValorImposto);
    SetParam(Qry,'eg',ftString,'Internal');
    Qry.ExecSQL;
  finally Qry.Connection.Free; Qry.Free; end;
end;

procedure TFiscalDocumentRepository.InserirAnaliseIA(const ADocId: Integer;
  const AModelo, APrompt, AResposta: string; const AAnomalias: Integer; const AConfianca: Double);
var Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'INSERT INTO AIAnalysisLog (DocumentId, Model, Prompt, Response, AnomaliesFound, ConfidenceScore) ' +
      'VALUES (:di,:md,:pr,:rs,:an,:sc)';
    SetParam(Qry,'di',ftInteger,ADocId); SetParam(Qry,'md',ftString,AModelo);
    SetParam(Qry,'pr',ftString,APrompt); SetParam(Qry,'rs',ftString,AResposta);
    SetParam(Qry,'an',ftInteger,AAnomalias); SetParam(Qry,'sc',ftFloat,AConfianca);
    Qry.ExecSQL;
  finally Qry.Connection.Free; Qry.Free; end;
end;

end.
