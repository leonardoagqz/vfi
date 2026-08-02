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
    Qry.SQL.Text := 'SELECT * FROM DocumentItem WHERE DocumentId = :id';
    Qry.Parameters.ParamByName('id').Value := ADocId;
    Qry.Open;
    while not Qry.Eof do
    begin
      Item := TDocumentItem.Create;
      PopularItem(Qry, Item);
      ADoc.Itens.Add(Item);
      Qry.Next;
    end;
  finally
    Qry.Connection.Free; Qry.Free;
  end;
end;

procedure TFiscalDocumentRepository.PopularCalculos(const ADocId: Integer; const ADoc: TFiscalDocument);
var
  Qry: TADOQuery;
  Calc: TTaxCalculation;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT * FROM TaxCalculation WHERE DocumentId = :id';
    Qry.Parameters.ParamByName('id').Value := ADocId;
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
    Qry.Connection.Free; Qry.Free;
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
    Qry.SQL.Text := 'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status ' +
      'FROM FiscalDocument ORDER BY IssueDate DESC';
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
    Qry.Connection.Free; Qry.Free;
  end;
end;

function TFiscalDocumentRepository.BuscarPorId(const AId: Integer): TFiscalDocument;
var
  Qry: TADOQuery;
begin
  Result := nil;
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status ' +
      'FROM FiscalDocument WHERE Id = :id';
    Qry.Parameters.ParamByName('id').Value := AId;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      Result := TFiscalDocument.Create;
      PopularDocumento(Qry, Result);
      PopularItens(Result.Id, Result);
      PopularCalculos(Result.Id, Result);
    end;
  finally
    Qry.Connection.Free; Qry.Free;
  end;
end;

function TFiscalDocumentRepository.BuscarPorFiltro(const ATipo: TTipoDocumento;
  const AStatus: string): TObjectList<TFiscalDocument>;
begin
  Result := BuscarTodos;
end;

function TFiscalDocumentRepository.InserirItem(const AItem: TDocumentItem): Integer;
var
  Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'INSERT INTO DocumentItem (DocumentId, ProductCode, ProductName, NCM, CFOP, ' +
      'Quantity, UnitValue, TotalValue, CST) VALUES (:docid,:cod,:nome,:ncm,:cfop,:qtd,:vu,:vt,:cst); SELECT SCOPE_IDENTITY()';
    Qry.Parameters.ParamByName('docid').Value := AItem.DocumentId;
    Qry.Parameters.ParamByName('cod').Value := AItem.CodigoProduto;
    Qry.Parameters.ParamByName('nome').Value := AItem.NomeProduto;
    Qry.Parameters.ParamByName('ncm').Value := AItem.NCM;
    Qry.Parameters.ParamByName('cfop').Value := AItem.CFOP;
    Qry.Parameters.ParamByName('qtd').Value := AItem.Quantidade;
    Qry.Parameters.ParamByName('vu').Value := AItem.ValorUnitario;
    Qry.Parameters.ParamByName('vt').Value := AItem.ValorTotal;
    Qry.Parameters.ParamByName('cst').Value := AItem.CST;
    Qry.Open;
    Result := Qry.Fields[0].AsInteger;
  finally
    Qry.Connection.Free; Qry.Free;
  end;
end;

procedure TFiscalDocumentRepository.Inserir(const ADocument: TFiscalDocument);
var
  Qry: TADOQuery;
  Item: TDocumentItem;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'INSERT INTO FiscalDocument (DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status) ' +
      'VALUES (:tipo,:chave,:num,:data,:cnpje,:nomee,:cnpjd,:nomed,:valor,:xml,:status); SELECT SCOPE_IDENTITY()';
    Qry.Parameters.ParamByName('tipo').Value := TipoDocumentoToStr(ADocument.Tipo);
    Qry.Parameters.ParamByName('chave').Value := ADocument.Chave;
    Qry.Parameters.ParamByName('num').Value := ADocument.Numero;
    Qry.Parameters.ParamByName('data').Value := ADocument.DataEmissao;
    Qry.Parameters.ParamByName('cnpje').Value := ADocument.CnpjEmitente;
    Qry.Parameters.ParamByName('nomee').Value := ADocument.NomeEmitente;
    Qry.Parameters.ParamByName('cnpjd').Value := ADocument.CnpjDestinatario;
    Qry.Parameters.ParamByName('nomed').Value := ADocument.NomeDestinatario;
    Qry.Parameters.ParamByName('valor').Value := ADocument.ValorTotal;
    Qry.Parameters.ParamByName('xml').Value := ADocument.XmlContent;
    Qry.Parameters.ParamByName('status').Value := StatusToStr(ADocument.Status);
    Qry.Open;
    ADocument.Id := Qry.Fields[0].AsInteger;
  finally
    Qry.Connection.Free; Qry.Free;
  end;

  for Item in ADocument.Itens do
  begin
    Item.DocumentId := ADocument.Id;
    Item.Id := InserirItem(Item);
  end;
end;

procedure TFiscalDocumentRepository.AtualizarStatus(const AId: Integer; const AStatus: TStatusDocumento);
var
  Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'UPDATE FiscalDocument SET Status = :status, UpdatedAt = GETDATE() WHERE Id = :id';
    Qry.Parameters.ParamByName('status').Value := StatusToStr(AStatus);
    Qry.Parameters.ParamByName('id').Value := AId;
    Qry.ExecSQL;
  finally
    Qry.Connection.Free; Qry.Free;
  end;
end;

function TFiscalDocumentRepository.ExisteChave(const AChave: string): Boolean;
var
  Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'SELECT COUNT(*) FROM FiscalDocument WHERE DocumentKey = :chave';
    Qry.Parameters.ParamByName('chave').Value := AChave;
    Qry.Open;
    Result := Qry.Fields[0].AsInteger > 0;
  finally
    Qry.Connection.Free; Qry.Free;
  end;
end;

procedure TFiscalDocumentRepository.Excluir(const AId: Integer);
var
  Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'DELETE FROM AIAnalysisLog WHERE DocumentId = :id'; Qry.Parameters.ParamByName('id').Value := AId; Qry.ExecSQL;
    Qry.SQL.Text := 'DELETE FROM TaxCalculation WHERE DocumentId = :id'; Qry.Parameters.ParamByName('id').Value := AId; Qry.ExecSQL;
    Qry.SQL.Text := 'DELETE FROM DocumentItem WHERE DocumentId = :id'; Qry.Parameters.ParamByName('id').Value := AId; Qry.ExecSQL;
    Qry.SQL.Text := 'DELETE FROM FiscalDocument WHERE Id = :id'; Qry.Parameters.ParamByName('id').Value := AId; Qry.ExecSQL;
  finally
    Qry.Connection.Free; Qry.Free;
  end;
end;

procedure TFiscalDocumentRepository.InserirCalculo(const ACalculo: TTaxCalculation);
var
  Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'INSERT INTO TaxCalculation (DocumentId, ItemId, TaxType, TaxBase, TaxRate, TaxValue, CalculationEngine) ' +
      'VALUES (:docid,:itemid,:taxtype,:base,:rate,:value,:engine)';
    Qry.Parameters.ParamByName('docid').Value := ACalculo.DocumentId;
    Qry.Parameters.ParamByName('itemid').Value := ACalculo.ItemId;
    Qry.Parameters.ParamByName('taxtype').Value := ImpostoToStr(ACalculo.TipoImposto);
    Qry.Parameters.ParamByName('base').Value := ACalculo.BaseCalculo;
    Qry.Parameters.ParamByName('rate').Value := ACalculo.Aliquota;
    Qry.Parameters.ParamByName('value').Value := ACalculo.ValorImposto;
    Qry.Parameters.ParamByName('engine').Value := 'Internal';
    Qry.ExecSQL;
  finally
    Qry.Connection.Free; Qry.Free;
  end;
end;

procedure TFiscalDocumentRepository.InserirAnaliseIA(const ADocId: Integer;
  const AModelo, APrompt, AResposta: string; const AAnomalias: Integer; const AConfianca: Double);
var
  Qry: TADOQuery;
begin
  Qry := CriarQuery;
  try
    Qry.SQL.Text := 'INSERT INTO AIAnalysisLog (DocumentId, Model, Prompt, Response, AnomaliesFound, ConfidenceScore) ' +
      'VALUES (:docid,:model,:prompt,:response,:anomalies,:score)';
    Qry.Parameters.ParamByName('docid').Value := ADocId;
    Qry.Parameters.ParamByName('model').Value := AModelo;
    Qry.Parameters.ParamByName('prompt').Value := APrompt;
    Qry.Parameters.ParamByName('response').Value := AResposta;
    Qry.Parameters.ParamByName('anomalies').Value := AAnomalias;
    Qry.Parameters.ParamByName('score').Value := AConfianca;
    Qry.ExecSQL;
  finally
    Qry.Connection.Free; Qry.Free;
  end;
end;

end.
