unit VFI.Data.Repository;

interface

uses
  System.SysUtils, System.Generics.Collections, System.StrUtils,
  Data.DB, Data.Win.ADODB,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TFiscalDocumentRepository = class(TInterfacedObject, IFiscalDocumentRepository)
  private
    procedure PreencherDocumento(const AConsulta: TADOQuery; const ADoc: TFiscalDocument);
    procedure PreencherItem(const AConsulta: TADOQuery; const AItem: TDocumentItem);
    procedure PreencherItens(const ADocId: Integer; const ADoc: TFiscalDocument);
    procedure PreencherCalculos(const ADocId: Integer; const ADoc: TFiscalDocument);
    function InserirItem(const AItem: TDocumentItem): Integer;
  public
    function BuscarTodos: TObjectList<TFiscalDocument>;
    function BuscarPorId(const AIdentificador: Integer): TFiscalDocument;
    function BuscarPorFiltro(const ATipo: TTipoDocumento; const AStatus: string): TObjectList<TFiscalDocument>;
    procedure Inserir(const ADocument: TFiscalDocument);
    procedure AtualizarStatus(const AIdentificador: Integer; const AStatus: TStatusDocumento);
    function ExisteChave(const AChave: string): Boolean;
    procedure Excluir(const AIdentificador: Integer);
    procedure InserirCalculo(const ACalculo: TTaxCalculation);
    procedure InserirAnaliseIA(const ADocId: Integer; const AModelo, APrompt, AResposta: string;
      const AAnomalias: Integer; const AConfianca: Double);
  end;

implementation

uses
  VFI.Data.Connection;

function EscaparSql(const ATexto: string): string;
begin
  Result := QuotedStr(ATexto);
end;

function FloatParaSql(const AValor: Double): string;
begin
  Result := StringReplace(FloatToStr(AValor), ',', '.', []);
end;

function MoedaParaSql(const AValor: Currency): string;
begin
  Result := StringReplace(CurrToStr(AValor), ',', '.', []);
end;

function DataParaSql(const AData: TDateTime): string;
begin
  Result := QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', AData));
end;

function CriarConsulta: TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := TConnectionFactory.CriarConexao;
end;

procedure TFiscalDocumentRepository.PreencherDocumento(const AConsulta: TADOQuery; const ADoc: TFiscalDocument);
begin
  ADoc.Id := AConsulta.FieldByName('Id').AsInteger;
  ADoc.Tipo := StrToTipoDocumento(AConsulta.FieldByName('DocumentType').AsString);
  ADoc.Chave := AConsulta.FieldByName('DocumentKey').AsString;
  ADoc.Numero := AConsulta.FieldByName('DocumentNumber').AsString;
  ADoc.DataEmissao := AConsulta.FieldByName('IssueDate').AsDateTime;
  ADoc.CnpjEmitente := AConsulta.FieldByName('IssuerCNPJ').AsString;
  ADoc.NomeEmitente := AConsulta.FieldByName('IssuerName').AsString;
  ADoc.CnpjDestinatario := AConsulta.FieldByName('RecipientCNPJ').AsString;
  ADoc.NomeDestinatario := AConsulta.FieldByName('RecipientName').AsString;
  ADoc.ValorTotal := AConsulta.FieldByName('TotalValue').AsCurrency;
  ADoc.XmlContent := AConsulta.FieldByName('XMLContent').AsString;
end;

procedure TFiscalDocumentRepository.PreencherItem(const AConsulta: TADOQuery; const AItem: TDocumentItem);
begin
  AItem.Id := AConsulta.FieldByName('Id').AsInteger;
  AItem.DocumentId := AConsulta.FieldByName('DocumentId').AsInteger;
  AItem.CodigoProduto := AConsulta.FieldByName('ProductCode').AsString;
  AItem.NomeProduto := AConsulta.FieldByName('ProductName').AsString;
  AItem.NCM := AConsulta.FieldByName('NCM').AsString;
  AItem.CFOP := AConsulta.FieldByName('CFOP').AsString;
  AItem.Quantidade := AConsulta.FieldByName('Quantity').AsFloat;
  AItem.ValorUnitario := AConsulta.FieldByName('UnitValue').AsCurrency;
  AItem.ValorTotal := AConsulta.FieldByName('TotalValue').AsCurrency;
  AItem.CST := AConsulta.FieldByName('CST').AsString;
end;

procedure TFiscalDocumentRepository.PreencherItens(const ADocId: Integer; const ADoc: TFiscalDocument);
var Consulta: TADOQuery; Item: TDocumentItem;
begin
  Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := 'SELECT * FROM DocumentItem WHERE DocumentId = ' + IntToStr(ADocId);
    Consulta.Open;
    while not Consulta.Eof do begin
      Item := TDocumentItem.Create; PreencherItem(Consulta, Item);
      ADoc.Itens.Add(Item); Consulta.Next;
    end;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

procedure TFiscalDocumentRepository.PreencherCalculos(const ADocId: Integer; const ADoc: TFiscalDocument);
var Consulta: TADOQuery; Calc: TTaxCalculation;
begin
  Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := 'SELECT * FROM TaxCalculation WHERE DocumentId = ' + IntToStr(ADocId);
    Consulta.Open;
    while not Consulta.Eof do begin
      Calc := TTaxCalculation.Create;
      Calc.Id := Consulta.FieldByName('Id').AsInteger; Calc.DocumentId := ADocId;
      Calc.ItemId := Consulta.FieldByName('ItemId').AsInteger;
      Calc.TipoImposto := StrToImposto(Consulta.FieldByName('TaxType').AsString);
      Calc.BaseCalculo := Consulta.FieldByName('TaxBase').AsCurrency;
      Calc.Aliquota := Consulta.FieldByName('TaxRate').AsFloat;
      Calc.ValorImposto := Consulta.FieldByName('TaxValue').AsCurrency;
      Calc.Engine := ecInternal; ADoc.Calculos.Add(Calc); Consulta.Next;
    end;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

function TFiscalDocumentRepository.BuscarTodos: TObjectList<TFiscalDocument>;
var Consulta: TADOQuery; Doc: TFiscalDocument;
begin
  Result := TObjectList<TFiscalDocument>.Create(True); Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := 'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status ' +
      'FROM FiscalDocument ORDER BY IssueDate DESC';
    Consulta.Open;
    while not Consulta.Eof do begin
      Doc := TFiscalDocument.Create; PreencherDocumento(Consulta, Doc);
      PreencherItens(Doc.Id, Doc); PreencherCalculos(Doc.Id, Doc); Result.Add(Doc); Consulta.Next;
    end;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

function TFiscalDocumentRepository.BuscarPorId(const AIdentificador: Integer): TFiscalDocument;
var Consulta: TADOQuery;
begin
  Result := nil; Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := 'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status ' +
      'FROM FiscalDocument WHERE Id = ' + IntToStr(AIdentificador);
    Consulta.Open;
    if not Consulta.IsEmpty then begin
      Result := TFiscalDocument.Create; PreencherDocumento(Consulta, Result);
      PreencherItens(Result.Id, Result); PreencherCalculos(Result.Id, Result);
    end;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

function TFiscalDocumentRepository.BuscarPorFiltro(const ATipo: TTipoDocumento;
  const AStatus: string): TObjectList<TFiscalDocument>;
var Consulta: TADOQuery; Doc: TFiscalDocument; WhereStr: string;
begin
  Result := TObjectList<TFiscalDocument>.Create(True); Consulta := CriarConsulta;
  try
    WhereStr := '';
    if ATipo <> tdNFe then
      WhereStr := WhereStr + ' AND DocumentType = ' + EscaparSql(TipoDocumentoToStr(ATipo));
    if AStatus <> '' then
      WhereStr := WhereStr + ' AND Status = ' + EscaparSql(AStatus);
    Consulta.SQL.Text := 'SELECT Id, DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status ' +
      'FROM FiscalDocument WHERE 1=1' + WhereStr + ' ORDER BY IssueDate DESC';
    Consulta.Open;
    while not Consulta.Eof do begin
      Doc := TFiscalDocument.Create; PreencherDocumento(Consulta, Doc);
      PreencherItens(Doc.Id, Doc); PreencherCalculos(Doc.Id, Doc); Result.Add(Doc); Consulta.Next;
    end;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

function TFiscalDocumentRepository.InserirItem(const AItem: TDocumentItem): Integer;
var Consulta: TADOQuery;
begin
  Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := Format(
      'INSERT INTO DocumentItem (DocumentId, ProductCode, ProductName, NCM, CFOP, Quantity, UnitValue, TotalValue, CST) ' +
      'VALUES (%d,%s,%s,%s,%s,%s,%s,%s,%s); SELECT SCOPE_IDENTITY()',
      [AItem.DocumentId, EscaparSql(AItem.CodigoProduto), EscaparSql(AItem.NomeProduto),
       EscaparSql(AItem.NCM), EscaparSql(AItem.CFOP), FloatParaSql(AItem.Quantidade),
       MoedaParaSql(AItem.ValorUnitario), MoedaParaSql(AItem.ValorTotal), EscaparSql(AItem.CST)]);
    Consulta.Open; Result := Consulta.Fields[0].AsInteger;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

procedure TFiscalDocumentRepository.Inserir(const ADocument: TFiscalDocument);
var Consulta: TADOQuery; Item: TDocumentItem;
begin
  Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := Format(
      'INSERT INTO FiscalDocument (DocumentType, DocumentKey, DocumentNumber, IssueDate, ' +
      'IssuerCNPJ, IssuerName, RecipientCNPJ, RecipientName, TotalValue, XMLContent, Status) ' +
      'VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s); SELECT SCOPE_IDENTITY()',
      [EscaparSql(TipoDocumentoToStr(ADocument.Tipo)), EscaparSql(ADocument.Chave),
       EscaparSql(ADocument.Numero), DataParaSql(ADocument.DataEmissao),
       EscaparSql(ADocument.CnpjEmitente), EscaparSql(ADocument.NomeEmitente),
       EscaparSql(ADocument.CnpjDestinatario), EscaparSql(ADocument.NomeDestinatario),
       MoedaParaSql(ADocument.ValorTotal), EscaparSql(ADocument.XmlContent),
       EscaparSql(StatusToStr(ADocument.Status))]);
    Consulta.Open; ADocument.Id := Consulta.Fields[0].AsInteger;
  finally Consulta.Connection.Free; Consulta.Free; end;
  for Item in ADocument.Itens do begin Item.DocumentId := ADocument.Id; Item.Id := InserirItem(Item); end;
end;

procedure TFiscalDocumentRepository.AtualizarStatus(const AIdentificador: Integer; const AStatus: TStatusDocumento);
var Consulta: TADOQuery;
begin
  Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := Format('UPDATE FiscalDocument SET Status = %s, UpdatedAt = GETDATE() WHERE Id = %d',
      [EscaparSql(StatusToStr(AStatus)), AIdentificador]);
    Consulta.ExecSQL;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

function TFiscalDocumentRepository.ExisteChave(const AChave: string): Boolean;
var Consulta: TADOQuery;
begin
  Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := 'SELECT COUNT(*) FROM FiscalDocument WHERE DocumentKey = ' + EscaparSql(AChave);
    Consulta.Open; Result := Consulta.Fields[0].AsInteger > 0;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

procedure TFiscalDocumentRepository.Excluir(const AIdentificador: Integer);
var Consulta: TADOQuery;
begin
  Consulta := CriarConsulta;
  try
    Consulta.Connection.BeginTrans;
    Consulta.SQL.Text := 'DELETE FROM AIAnalysisLog WHERE DocumentId = ' + IntToStr(AIdentificador); Consulta.ExecSQL;
    Consulta.SQL.Text := 'DELETE FROM TaxCalculation WHERE DocumentId = ' + IntToStr(AIdentificador); Consulta.ExecSQL;
    Consulta.SQL.Text := 'DELETE FROM DocumentItem WHERE DocumentId = ' + IntToStr(AIdentificador); Consulta.ExecSQL;
    Consulta.SQL.Text := 'DELETE FROM FiscalDocument WHERE Id = ' + IntToStr(AIdentificador); Consulta.ExecSQL;
    Consulta.Connection.CommitTrans;
  except
    Consulta.Connection.RollbackTrans; raise;
  end;
  Consulta.Connection.Free; Consulta.Free;
end;

procedure TFiscalDocumentRepository.InserirCalculo(const ACalculo: TTaxCalculation);
var Consulta: TADOQuery;
begin
  Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := Format(
      'INSERT INTO TaxCalculation (DocumentId, ItemId, TaxType, TaxBase, TaxRate, TaxValue, CalculationEngine) ' +
      'VALUES (%d,%d,%s,%s,%s,%s,%s)',
      [ACalculo.DocumentId, ACalculo.ItemId, EscaparSql(ImpostoToStr(ACalculo.TipoImposto)),
       MoedaParaSql(ACalculo.BaseCalculo), FloatParaSql(ACalculo.Aliquota),
       MoedaParaSql(ACalculo.ValorImposto), EscaparSql('Internal')]);
    Consulta.ExecSQL;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

procedure TFiscalDocumentRepository.InserirAnaliseIA(const ADocId: Integer;
  const AModelo, APrompt, AResposta: string; const AAnomalias: Integer; const AConfianca: Double);
var Consulta: TADOQuery;
begin
  Consulta := CriarConsulta;
  try
    Consulta.SQL.Text := Format(
      'INSERT INTO AIAnalysisLog (DocumentId, Model, Prompt, Response, AnomaliesFound, ConfidenceScore) ' +
      'VALUES (%d,%s,%s,%s,%d,%s)',
      [ADocId, EscaparSql(AModelo), EscaparSql(APrompt), EscaparSql(AResposta),
       AAnomalias, FloatParaSql(AConfianca)]);
    Consulta.ExecSQL;
  finally Consulta.Connection.Free; Consulta.Free; end;
end;

end.
