unit VFI.Data.Repository;

interface

uses
  System.SysUtils, System.Generics.Collections,
  Data.DB, Data.Win.ADODB,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TFiscalDocumentRepository = class(TInterfacedObject, IFiscalDocumentRepository)
  private
    procedure PopularDocumento(const AQuery: TADOQuery; const ADoc: TFiscalDocument);
    procedure PopularItem(const AQuery: TADOQuery; const AItem: TDocumentItem);
    procedure PopularItens(const ADocId: Integer; const ADoc: TFiscalDocument);
    procedure PopularCalculos(const ADocId: Integer; const ADoc: TFiscalDocument);
    function InserirItem(const AItem: TDocumentItem): Integer;
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

procedure AdicionarParametro(const AQuery: TADOQuery; const ANome: string;
  ATipo: TFieldType; const AValor: Variant);
var
  Param: TParameter;
begin
  Param := AQuery.Parameters.AddParameter;
  Param.Name := ANome;
  Param.DataType := ATipo;
  Param.Direction := pdInput;
  Param.Value := AValor;
end;

function CriarConsulta: TADOQuery;
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
  ADoc.Status := StrToStatus(AQuery.FieldByName('Status').AsString);
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
  Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'SELECT * FROM DocumentItem WHERE DocumentId = :id';
    AdicionarParametro(Qry, 'id', ftInteger, ADocId);
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
  Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'SELECT * FROM TaxCalculation WHERE DocumentId = :id';
    AdicionarParametro(Qry, 'id', ftInteger, ADocId);
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
  Result := TObjectList<TFiscalDocument>.Create(True); Qry := CriarConsulta;
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
  Result := nil; Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status ' +
      'FROM FiscalDocument WHERE Id = :id';
    AdicionarParametro(Qry, 'id', ftInteger, AId);
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
  Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'INSERT INTO DocumentItem (DocumentId, ProductCode, ProductName, NCM, CFOP, ' +
      'Quantity, UnitValue, TotalValue, CST) VALUES (:docid,:cod,:nome,:ncm,:cfop,:qtd,:vu,:vt,:cst); SELECT SCOPE_IDENTITY()';
    AdicionarParametro(Qry,'docid',ftInteger,AItem.DocumentId); AdicionarParametro(Qry,'cod',ftString,AItem.CodigoProduto);
    AdicionarParametro(Qry,'nome',ftString,AItem.NomeProduto); AdicionarParametro(Qry,'ncm',ftString,AItem.NCM);
    AdicionarParametro(Qry,'cfop',ftString,AItem.CFOP); AdicionarParametro(Qry,'qtd',ftFloat,AItem.Quantidade);
    AdicionarParametro(Qry,'vu',ftCurrency,AItem.ValorUnitario); AdicionarParametro(Qry,'vt',ftCurrency,AItem.ValorTotal);
    AdicionarParametro(Qry,'cst',ftString,AItem.CST);
    Qry.Open; Result := Qry.Fields[0].AsInteger;
  finally Qry.Connection.Free; Qry.Free; end;
end;

procedure TFiscalDocumentRepository.Inserir(const ADocument: TFiscalDocument);
var Qry: TADOQuery; Item: TDocumentItem;
begin
  Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'INSERT INTO FiscalDocument (DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status) ' +
      'VALUES (:tp,:ch,:num,:dt,:ce,:ne,:cd,:nd,:vl,:xml,:st); SELECT SCOPE_IDENTITY()';
    AdicionarParametro(Qry,'tp',ftString,TipoDocumentoToStr(ADocument.Tipo)); AdicionarParametro(Qry,'ch',ftString,ADocument.Chave);
    AdicionarParametro(Qry,'num',ftString,ADocument.Numero); AdicionarParametro(Qry,'dt',ftDateTime,ADocument.DataEmissao);
    AdicionarParametro(Qry,'ce',ftString,ADocument.CnpjEmitente); AdicionarParametro(Qry,'ne',ftString,ADocument.NomeEmitente);
    AdicionarParametro(Qry,'cd',ftString,ADocument.CnpjDestinatario); AdicionarParametro(Qry,'nd',ftString,ADocument.NomeDestinatario);
    AdicionarParametro(Qry,'vl',ftCurrency,ADocument.ValorTotal); AdicionarParametro(Qry,'xml',ftString,ADocument.XmlContent);
    AdicionarParametro(Qry,'st',ftString,StatusToStr(ADocument.Status));
    Qry.Open; ADocument.Id := Qry.Fields[0].AsInteger;
  finally Qry.Connection.Free; Qry.Free; end;
  for Item in ADocument.Itens do begin Item.DocumentId := ADocument.Id; Item.Id := InserirItem(Item); end;
end;

procedure TFiscalDocumentRepository.AtualizarStatus(const AId: Integer; const AStatus: TStatusDocumento);
var Qry: TADOQuery;
begin
  Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'UPDATE FiscalDocument SET Status = :st, UpdatedAt = GETDATE() WHERE Id = :id';
    AdicionarParametro(Qry,'st',ftString,StatusToStr(AStatus)); AdicionarParametro(Qry,'id',ftInteger,AId);
    Qry.ExecSQL;
  finally Qry.Connection.Free; Qry.Free; end;
end;

function TFiscalDocumentRepository.ExisteChave(const AChave: string): Boolean;
var Qry: TADOQuery;
begin
  Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'SELECT COUNT(*) FROM FiscalDocument WHERE DocumentKey = :ch';
    AdicionarParametro(Qry,'ch',ftString,AChave); Qry.Open;
    Result := Qry.Fields[0].AsInteger > 0;
  finally Qry.Connection.Free; Qry.Free; end;
end;

procedure TFiscalDocumentRepository.Excluir(const AId: Integer);
var Consulta: TADOQuery;
begin
  Consulta := CriarConsulta;
  try
    Consulta.Connection.BeginTrans;
    Consulta.SQL.Text := 'DELETE FROM AIAnalysisLog WHERE DocumentId = :id'; AdicionarParametro(Consulta,'id',ftInteger,AId); Consulta.ExecSQL;
    Consulta.SQL.Text := 'DELETE FROM TaxCalculation WHERE DocumentId = :id'; AdicionarParametro(Consulta,'id',ftInteger,AId); Consulta.ExecSQL;
    Consulta.SQL.Text := 'DELETE FROM DocumentItem WHERE DocumentId = :id'; AdicionarParametro(Consulta,'id',ftInteger,AId); Consulta.ExecSQL;
    Consulta.SQL.Text := 'DELETE FROM FiscalDocument WHERE Id = :id'; AdicionarParametro(Consulta,'id',ftInteger,AId); Consulta.ExecSQL;
    Consulta.Connection.CommitTrans;
  except
    Consulta.Connection.RollbackTrans;
    raise;
  end;
  Consulta.Connection.Free; Consulta.Free;
end;

procedure TFiscalDocumentRepository.InserirCalculo(const ACalculo: TTaxCalculation);
var Qry: TADOQuery;
begin
  Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'INSERT INTO TaxCalculation (DocumentId, ItemId, TaxType, TaxBase, TaxRate, TaxValue, CalculationEngine) ' +
      'VALUES (:di,:ii,:tt,:bc,:rt,:vl,:eg)';
    AdicionarParametro(Qry,'di',ftInteger,ACalculo.DocumentId); AdicionarParametro(Qry,'ii',ftInteger,ACalculo.ItemId);
    AdicionarParametro(Qry,'tt',ftString,ImpostoToStr(ACalculo.TipoImposto)); AdicionarParametro(Qry,'bc',ftCurrency,ACalculo.BaseCalculo);
    AdicionarParametro(Qry,'rt',ftFloat,ACalculo.Aliquota); AdicionarParametro(Qry,'vl',ftCurrency,ACalculo.ValorImposto);
    AdicionarParametro(Qry,'eg',ftString,'Internal');
    Qry.ExecSQL;
  finally Qry.Connection.Free; Qry.Free; end;
end;

procedure TFiscalDocumentRepository.InserirAnaliseIA(const ADocId: Integer;
  const AModelo, APrompt, AResposta: string; const AAnomalias: Integer; const AConfianca: Double);
var Qry: TADOQuery;
begin
  Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'INSERT INTO AIAnalysisLog (DocumentId, Model, Prompt, Response, AnomaliesFound, ConfidenceScore) ' +
      'VALUES (:di,:md,:pr,:rs,:an,:sc)';
    AdicionarParametro(Qry,'di',ftInteger,ADocId); AdicionarParametro(Qry,'md',ftString,AModelo);
    AdicionarParametro(Qry,'pr',ftString,APrompt); AdicionarParametro(Qry,'rs',ftString,AResposta);
    AdicionarParametro(Qry,'an',ftInteger,AAnomalias); AdicionarParametro(Qry,'sc',ftFloat,AConfianca);
    Qry.ExecSQL;
  finally Qry.Connection.Free; Qry.Free; end;
end;

end.
