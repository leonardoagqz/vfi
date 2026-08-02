unit VFI.UI.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.Grids,
  VFI.Domain.Interfaces, VFI.Domain.Entities, VFI.Domain.Enums;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel;
    lblTitle: TLabel;
    lblSub: TLabel;
    lblCount: TLabel;
    pnlToolbar: TPanel;
    btnImportar: TSpeedButton;
    btnImportarVarios: TSpeedButton;
    btnAtualizar: TSpeedButton;
    btnExcluir: TSpeedButton;
    btnAnalisarIA: TSpeedButton;
    Splitter1: TSplitter;
    pnlLeft: TPanel;
    lvDocs: TListView;
    pnlRight: TPanel;
    gbDetalhes: TGroupBox;
    lblTipo: TLabel;
    lblTipoVal: TLabel;
    lblNumero: TLabel;
    lblNumeroVal: TLabel;
    lblEmitente: TLabel;
    lblEmitenteVal: TLabel;
    lblCNPJE: TLabel;
    lblCNPJEVal: TLabel;
    lblDest: TLabel;
    lblDestVal: TLabel;
    lblCNPJD: TLabel;
    lblCNPJDVal: TLabel;
    lblValor: TLabel;
    lblValorVal: TLabel;
    lblStatus: TLabel;
    lblStatusVal: TLabel;
    ShapeStatus: TShape;
    gbValidacao: TGroupBox;
    memValidacao: TMemo;
    gbImpostos: TGroupBox;
    lvImpostos: TListView;
    gbItens: TGroupBox;
    lvItens: TListView;
    pnlBottom: TPanel;
    pcLog: TPageControl;
    tsLog: TTabSheet;
    memLog: TMemo;
    tsIA: TTabSheet;
    memIA: TMemo;
    pnlStatus: TPanel;
    lblStatusMsg: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnImportarClick(Sender: TObject);
    procedure btnImportarVariosClick(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnAnalisarIAClick(Sender: TObject);
    procedure lvDocsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    FController: IMainController;
    procedure AtualizarLista;
    procedure MostrarDetalhes(const AIndex: Integer);
    procedure LimparDetalhes;
    function ObterIdSelecionado: Integer;
    function ObterIndexSelecionado: Integer;
  public
    procedure AtualizarStatus(const AMsg: string);
    property Controller: IMainController read FController write FController;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  VFI.AppModule;

function FormatarCNPJ(const S: string): string;
begin
  Result := Trim(S);
  if Length(Result) = 14 then
    Result := Copy(Result,1,2) + '.' + Copy(Result,3,3) + '.' + Copy(Result,6,3) + '/' +
              Copy(Result,9,4) + '-' + Copy(Result,13,2);
end;

function FmtValor(const V: Currency): string;
begin
  Result := FormatFloat('#,##0.00', V);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
  DoubleBuffered := True;

  lvDocs.ViewStyle := vsReport;
  lvDocs.RowSelect := True;
  lvDocs.GridLines := True;
  lvDocs.Columns.Add.Caption := 'ID';     lvDocs.Columns[0].Width := 40;
  lvDocs.Columns.Add.Caption := 'Tipo';   lvDocs.Columns[1].Width := 48;
  lvDocs.Columns.Add.Caption := 'Nro';    lvDocs.Columns[2].Width := 70;
  lvDocs.Columns.Add.Caption := 'Emitente'; lvDocs.Columns[3].Width := 180;
  lvDocs.Columns.Add.Caption := 'Valor';  lvDocs.Columns[4].Width := 100;
  lvDocs.Columns.Add.Caption := 'Status'; lvDocs.Columns[5].Width := 80;

  lvItens.ViewStyle := vsReport; lvItens.RowSelect := True; lvItens.GridLines := True;
  lvItens.Columns.Add.Caption := 'Codigo'; lvItens.Columns[0].Width := 65;
  lvItens.Columns.Add.Caption := 'Produto'; lvItens.Columns[1].Width := 140;
  lvItens.Columns.Add.Caption := 'Qtd';    lvItens.Columns[2].Width := 45;
  lvItens.Columns.Add.Caption := 'Vlr Total'; lvItens.Columns[3].Width := 80;
  lvItens.Columns.Add.Caption := 'NCM';     lvItens.Columns[4].Width := 70;
  lvItens.Columns.Add.Caption := 'CFOP';    lvItens.Columns[5].Width := 55;

  lvImpostos.ViewStyle := vsReport; lvImpostos.RowSelect := True; lvImpostos.GridLines := True;
  lvImpostos.Columns.Add.Caption := 'Imposto'; lvImpostos.Columns[0].Width := 60;
  lvImpostos.Columns.Add.Caption := 'Base';    lvImpostos.Columns[1].Width := 90;
  lvImpostos.Columns.Add.Caption := 'Aliquota'; lvImpostos.Columns[2].Width := 60;
  lvImpostos.Columns.Add.Caption := 'Valor';    lvImpostos.Columns[3].Width := 90;
  lvImpostos.Columns.Add.Caption := 'CST';      lvImpostos.Columns[4].Width := 40;

  pcLog.ActivePage := tsLog;
  LimparDetalhes;
  AtualizarStatus('Pronto. Importe XMLs fiscais para comecar. Os impostos sao extraidos automaticamente.');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FController := nil;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift = [ssCtrl] then
    case Key of
      Ord('I'): btnImportarClick(Self);
      Ord('A'): btnAnalisarIAClick(Self);
      Ord('R'): btnAtualizarClick(Self);
    end
  else if Key = VK_DELETE then
    btnExcluirClick(Self);
end;

procedure TfrmMain.AtualizarStatus(const AMsg: string);
begin
  lblStatusMsg.Caption := AMsg;
  memLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AMsg);
end;

procedure TfrmMain.LimparDetalhes;
begin
  lblTipoVal.Caption := '-'; lblNumeroVal.Caption := '-';
  lblEmitenteVal.Caption := '-'; lblCNPJEVal.Caption := '-';
  lblDestVal.Caption := '-'; lblCNPJDVal.Caption := '-';
  lblValorVal.Caption := '-'; lblStatusVal.Caption := '-';
  ShapeStatus.Brush.Color := clBtnFace;
  lvItens.Items.Clear;
  lvImpostos.Items.Clear;
  memValidacao.Clear;
end;

procedure TfrmMain.AtualizarLista;
var
  i, Qtd: Integer;
  Doc: TFiscalDocument;
  Item: TListItem;
begin
  if not Assigned(FController) then Exit;
  Qtd := FController.QuantidadeDocumentos;
  lblCount.Caption := Format('%d documento(s)', [Qtd]);

  lvDocs.Items.BeginUpdate;
  try
    lvDocs.Items.Clear;
    for i := 0 to Qtd - 1 do
    begin
      Doc := FController.ObterDocumento(i);
      if not Assigned(Doc) then Continue;
      Item := lvDocs.Items.Add;
      Item.Caption := IntToStr(Doc.Id);
      Item.SubItems.Add(TipoDocumentoToStr(Doc.Tipo));
      Item.SubItems.Add(Doc.Numero);
      Item.SubItems.Add(Copy(Doc.NomeEmitente, 1, 28));
      Item.SubItems.Add(FmtValor(Doc.ValorTotal));
      Item.SubItems.Add(StatusToStr(Doc.Status));
    end;
  finally
    lvDocs.Items.EndUpdate;
  end;

  if lvDocs.Items.Count > 0 then
  begin
    lvDocs.Selected := lvDocs.Items[0];
    lvDocs.ItemFocused := lvDocs.Items[0];
    MostrarDetalhes(0);
  end
  else
    LimparDetalhes;
end;

procedure TfrmMain.MostrarDetalhes(const AIndex: Integer);
var
  Doc: TFiscalDocument;
  i: Integer;
  Item: TDocumentItem;
  Calc: TTaxCalculation;
  LI: TListItem;
  Val: TResultadoValidacao;
begin
  if not Assigned(FController) then Exit;
  Doc := FController.ObterDocumento(AIndex);
  if not Assigned(Doc) then begin LimparDetalhes; Exit; end;

  lblTipoVal.Caption := TipoDocumentoToStr(Doc.Tipo);
  lblNumeroVal.Caption := Doc.Numero;
  lblEmitenteVal.Caption := Doc.NomeEmitente;
  lblCNPJEVal.Caption := FormatarCNPJ(Doc.CnpjEmitente);
  lblDestVal.Caption := Doc.NomeDestinatario;
  lblCNPJDVal.Caption := FormatarCNPJ(Doc.CnpjDestinatario);
  lblValorVal.Caption := 'R$ ' + FmtValor(Doc.ValorTotal);
  lblStatusVal.Caption := StatusToStr(Doc.Status);

  case Doc.Status of
    stPendente:  begin ShapeStatus.Brush.Color := $004090FF; lblStatusVal.Font.Color := clNavy; end;
    stValidado:  begin ShapeStatus.Brush.Color := $0040B840; lblStatusVal.Font.Color := clGreen; end;
    stRejeitado: begin ShapeStatus.Brush.Color := $004040F0; lblStatusVal.Font.Color := clMaroon; end;
  end;

  memValidacao.Clear;
  Val := TAppModule.Validator.ValidarDocumento(Doc);
  if Val.IsValid then
    memValidacao.Lines.Add('Validacao: OK - CNPJ, NCM, CFOP e chave validos.')
  else
  begin
    memValidacao.Lines.Add(Format('Validacao: REJEITADO - %d problema(s):', [Val.Erros.Count]));
    for i := 0 to Val.Erros.Count - 1 do
      memValidacao.Lines.Add('  ' + Val.Erros[i]);
  end;

  gbImpostos.Caption := Format(' Impostos (%d) ', [Doc.Calculos.Count]);
  lvImpostos.Items.BeginUpdate;
  try
    lvImpostos.Items.Clear;
    for i := 0 to Doc.Calculos.Count - 1 do
    begin
      Calc := Doc.Calculos[i];
      LI := lvImpostos.Items.Add;
      LI.Caption := ImpostoToStr(Calc.TipoImposto);
      LI.SubItems.Add(FmtValor(Calc.BaseCalculo));
      LI.SubItems.Add(FormatFloat('0.##', Calc.Aliquota) + '%');
      LI.SubItems.Add(FmtValor(Calc.ValorImposto));
      LI.SubItems.Add(Calc.CST);
    end;
  finally
    lvImpostos.Items.EndUpdate;
  end;

  gbItens.Caption := Format(' Itens (%d) ', [Doc.Itens.Count]);
  lvItens.Items.BeginUpdate;
  try
    lvItens.Items.Clear;
    for i := 0 to Doc.Itens.Count - 1 do
    begin
      Item := Doc.Itens[i];
      LI := lvItens.Items.Add;
      LI.Caption := Item.CodigoProduto;
      LI.SubItems.Add(Item.NomeProduto);
      LI.SubItems.Add(FormatFloat('0.####', Item.Quantidade));
      LI.SubItems.Add(FmtValor(Item.ValorTotal));
      LI.SubItems.Add(Item.NCM);
      LI.SubItems.Add(Item.CFOP);
    end;
  finally
    lvItens.Items.EndUpdate;
  end;
end;

function TfrmMain.ObterIdSelecionado: Integer;
begin
  Result := StrToIntDef(lvDocs.Selected.Caption, 0);
end;

function TfrmMain.ObterIndexSelecionado: Integer;
begin
  if Assigned(lvDocs.Selected) then Result := lvDocs.Selected.Index else Result := -1;
end;

procedure TfrmMain.lvDocsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and Assigned(Item) then MostrarDetalhes(Item.Index);
end;

procedure TfrmMain.btnAtualizarClick(Sender: TObject);
begin
  if not Assigned(FController) then Exit;
  FController.CarregarDocumentos;
  AtualizarLista;
end;

procedure TfrmMain.btnAnalisarIAClick(Sender: TObject);
var
  Id, Idx: Integer;
  Doc: TFiscalDocument;
  R: TResultadoIA;
begin
  Id := ObterIdSelecionado;
  if Id = 0 then begin AtualizarStatus('Selecione um documento na lista.'); Exit; end;

  Idx := ObterIndexSelecionado;
  Doc := FController.ObterDocumento(Idx);
  if not Assigned(Doc) then Exit;

  memIA.Clear;
  memIA.Lines.Add(Format('Documento: %s #%s', [TipoDocumentoToStr(Doc.Tipo), Doc.Numero]));
  memIA.Lines.Add(Format('Emitente: %s (CNPJ: %s)', [Doc.NomeEmitente, FormatarCNPJ(Doc.CnpjEmitente)]));
  memIA.Lines.Add(Format('Valor: R$ %s | Itens: %d | Impostos extraidos: %d',
    [FmtValor(Doc.ValorTotal), Doc.Itens.Count, Doc.Calculos.Count]));
  memIA.Lines.Add('');

  pcLog.ActivePage := tsIA;
  Application.ProcessMessages;

  FController.AnalisarComIA(Id);
  R := FController.ObterUltimoResultadoIA;

  memIA.Lines.Add(Format('Modelo IA: %s', [R.Modelo]));
  memIA.Lines.Add(Format('Anomalias detectadas: %d', [R.AnomaliasEncontradas]));
  memIA.Lines.Add(Format('Confianca da analise: %.0f%%', [R.Confianca * 100]));
  memIA.Lines.Add('');
  memIA.Lines.Add('Analise:');
  if R.Resposta <> '' then
    memIA.Lines.Add(R.Resposta)
  else
    memIA.Lines.Add('[Simulacao] Chave de API DeepSeek nao configurada. Analise offline.');
end;

procedure TfrmMain.btnImportarClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  if not Assigned(FController) then Exit;
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := 'Importar XML Fiscal (NFe / CTe)';
    Dlg.Filter := 'XML Fiscal (*.xml)|*.xml';
    Dlg.InitialDir := ExtractFilePath(ParamStr(0)) + '..\..\..\..\docs\xml-exemplos';
    if Dlg.Execute then
    begin
      FController.ImportarXml(Dlg.FileName);
      AtualizarLista;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmMain.btnImportarVariosClick(Sender: TObject);
var
  Dlg: TOpenDialog;
  i: Integer;
  Arquivos: TArray<string>;
begin
  if not Assigned(FController) then Exit;
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := 'Importar Varios XMLs';
    Dlg.Filter := 'XML (*.xml)|*.xml';
    Dlg.Options := [ofAllowMultiSelect, ofFileMustExist];
    Dlg.InitialDir := ExtractFilePath(ParamStr(0)) + '..\..\..\..\docs\xml-exemplos';
    if Dlg.Execute then
    begin
      SetLength(Arquivos, Dlg.Files.Count);
      for i := 0 to Dlg.Files.Count - 1 do
        Arquivos[i] := Dlg.Files[i];
      FController.ImportarMultiplosXmls(Arquivos);
      AtualizarLista;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmMain.btnExcluirClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := ObterIdSelecionado;
  if Id = 0 then begin AtualizarStatus('Selecione um documento.'); Exit; end;
  if MessageDlg(Format('Excluir doc #%d?', [Id]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FController.ExcluirDocumento(Id);
    AtualizarLista;
  end;
end;

end.
