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

procedure DefinirParametro(const AConsulta: TADOQuery; const ANome: string; const AValor: Variant);
begin
  AConsulta.Parameters.ParamByName(ANome).Value := AValor;
end;

function CriarConsulta: TADOQuery;
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
    DefinirParametro(Qry, 'id', ADocId);
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
    DefinirParametro(Qry, 'id', ADocId);
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
    DefinirParametro(Qry, 'id', AId);
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
    DefinirParametro(Qry,'docid',AItem.DocumentId); DefinirParametro(Qry,'cod',AItem.CodigoProduto);
    DefinirParametro(Qry,'nome',AItem.NomeProduto); DefinirParametro(Qry,'ncm',AItem.NCM);
    DefinirParametro(Qry,'cfop',AItem.CFOP); DefinirParametro(Qry,'qtd',AItem.Quantidade);
    DefinirParametro(Qry,'vu',AItem.ValorUnitario); DefinirParametro(Qry,'vt',AItem.ValorTotal);
    DefinirParametro(Qry,'cst',AItem.CST);
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
    DefinirParametro(Qry,'tp',TipoDocumentoToStr(ADocument.Tipo)); DefinirParametro(Qry,'ch',ADocument.Chave);
    DefinirParametro(Qry,'num',ADocument.Numero); DefinirParametro(Qry,'dt',ADocument.DataEmissao);
    DefinirParametro(Qry,'ce',ADocument.CnpjEmitente); DefinirParametro(Qry,'ne',ADocument.NomeEmitente);
    DefinirParametro(Qry,'cd',ADocument.CnpjDestinatario); DefinirParametro(Qry,'nd',ADocument.NomeDestinatario);
    DefinirParametro(Qry,'vl',ADocument.ValorTotal); DefinirParametro(Qry,'xml',ADocument.XmlContent);
    DefinirParametro(Qry,'st',StatusToStr(ADocument.Status));
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
    DefinirParametro(Qry,'st',StatusToStr(AStatus)); DefinirParametro(Qry,'id',AId);
    Qry.ExecSQL;
  finally Qry.Connection.Free; Qry.Free; end;
end;

function TFiscalDocumentRepository.ExisteChave(const AChave: string): Boolean;
var Qry: TADOQuery;
begin
  Qry := CriarConsulta;
  try
    Qry.SQL.Text := 'SELECT COUNT(*) FROM FiscalDocument WHERE DocumentKey = :ch';
    DefinirParametro(Qry,'ch',AChave); Qry.Open;
    Result := Qry.Fields[0].AsInteger > 0;
  finally Qry.Connection.Free; Qry.Free; end;
end;

procedure TFiscalDocumentRepository.Excluir(const AId: Integer);
var Consulta: TADOQuery;
begin
  Consulta := CriarConsulta;
  try
    Consulta.Connection.BeginTrans;
    Consulta.SQL.Text := 'DELETE FROM AIAnalysisLog WHERE DocumentId = :id'; DefinirParametro(Consulta,'id',AId); Consulta.ExecSQL;
    Consulta.SQL.Text := 'DELETE FROM TaxCalculation WHERE DocumentId = :id'; DefinirParametro(Consulta,'id',AId); Consulta.ExecSQL;
    Consulta.SQL.Text := 'DELETE FROM DocumentItem WHERE DocumentId = :id'; DefinirParametro(Consulta,'id',AId); Consulta.ExecSQL;
    Consulta.SQL.Text := 'DELETE FROM FiscalDocument WHERE Id = :id'; DefinirParametro(Consulta,'id',AId); Consulta.ExecSQL;
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
    DefinirParametro(Qry,'di',ACalculo.DocumentId); DefinirParametro(Qry,'ii',ACalculo.ItemId);
    DefinirParametro(Qry,'tt',ImpostoToStr(ACalculo.TipoImposto)); DefinirParametro(Qry,'bc',ACalculo.BaseCalculo);
    DefinirParametro(Qry,'rt',ACalculo.Aliquota); DefinirParametro(Qry,'vl',ACalculo.ValorImposto);
    DefinirParametro(Qry,'eg','Internal');
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
    DefinirParametro(Qry,'di',ADocId); DefinirParametro(Qry,'md',AModelo);
    DefinirParametro(Qry,'pr',APrompt); DefinirParametro(Qry,'rs',AResposta);
    DefinirParametro(Qry,'an',AAnomalias); DefinirParametro(Qry,'sc',AConfianca);
    Qry.ExecSQL;
  finally Qry.Connection.Free; Qry.Free; end;
end;

end.
