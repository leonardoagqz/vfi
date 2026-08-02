unit VFI.UI.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.Menus, Vcl.Grids,
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
    btnValidar: TSpeedButton;
    btnCalcular: TSpeedButton;
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
    procedure btnValidarClick(Sender: TObject);
    procedure btnCalcularClick(Sender: TObject);
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
  VFI.UI.MainController;

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

const
  COR_PENDENTE  = $004090FF;
  COR_VALIDADO  = $0040B840;
  COR_REJEITADO = $004040F0;
  COR_FUNDO     = $00FFFFFF;
  COR_SELECAO   = $00FFEEDD;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  KeyPreview := True;
  DoubleBuffered := True;

  lvDocs.ViewStyle := vsReport;
  lvDocs.RowSelect := True;
  lvDocs.GridLines := True;
  lvDocs.Columns.Add.Caption := 'ID';       lvDocs.Columns[0].Width := 40;
  lvDocs.Columns.Add.Caption := 'Tipo';     lvDocs.Columns[1].Width := 48;
  lvDocs.Columns.Add.Caption := 'Numero';   lvDocs.Columns[2].Width := 70;
  lvDocs.Columns.Add.Caption := 'Emitente'; lvDocs.Columns[3].Width := 200;
  lvDocs.Columns.Add.Caption := 'Valor';    lvDocs.Columns[4].Width := 100;
  lvDocs.Columns.Add.Caption := 'Status';   lvDocs.Columns[5].Width := 80;

  lvItens.ViewStyle := vsReport;
  lvItens.RowSelect := True;
  lvItens.GridLines := True;
  lvItens.Columns.Add.Caption := 'Codigo';   lvItens.Columns[0].Width := 70;
  lvItens.Columns.Add.Caption := 'Produto';  lvItens.Columns[1].Width := 140;
  lvItens.Columns.Add.Caption := 'Qtd';      lvItens.Columns[2].Width := 50;
  lvItens.Columns.Add.Caption := 'Vlr Unit'; lvItens.Columns[3].Width := 80;
  lvItens.Columns.Add.Caption := 'Vlr Total'; lvItens.Columns[4].Width := 80;
  lvItens.Columns.Add.Caption := 'NCM';      lvItens.Columns[5].Width := 80;
  lvItens.Columns.Add.Caption := 'CFOP';     lvItens.Columns[5].Width := 60;

  pcLog.ActivePage := tsLog;
  LimparDetalhes;
  AtualizarStatus('Pronto. Use Importar XML ou Importar Varios para comecar.');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FController := nil;
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift = [ssCtrl] then
  begin
    case Key of
      Ord('I'): btnImportarClick(Self);
      Ord('V'): btnValidarClick(Self);
      Ord('C'): btnCalcularClick(Self);
      Ord('A'): btnAnalisarIAClick(Self);
      Ord('R'): btnAtualizarClick(Self);
    end;
  end
  else if Key = VK_DELETE then
    btnExcluirClick(Self);
end;

procedure TfrmMain.AtualizarStatus(const AMsg: string);
begin
  lblStatusMsg.Caption := AMsg;
  memLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AMsg);

  if Pos('ERRO', AMsg) > 0 then
    pnlStatus.Color := $004040F0
  else if Pos('IMPORTADO', AMsg) > 0 then
    pnlStatus.Color := $00A0D0F0
  else if Pos('VALIDO', AMsg) > 0 then
    pnlStatus.Color := $00B0E0B0
  else if Pos('REJEITADO', AMsg) > 0 then
    pnlStatus.Color := $00C0C0F0
  else
    pnlStatus.Color := clBtnFace;
end;

procedure TfrmMain.LimparDetalhes;
begin
  lblTipoVal.Caption := '-';
  lblNumeroVal.Caption := '-';
  lblEmitenteVal.Caption := '-';
  lblCNPJEVal.Caption := '-';
  lblDestVal.Caption := '-';
  lblCNPJDVal.Caption := '-';
  lblValorVal.Caption := '-';
  lblStatusVal.Caption := '-';
  ShapeStatus.Brush.Color := clBtnFace;
  lvItens.Items.Clear;
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
      Item.SubItems.Add(Copy(Doc.NomeEmitente, 1, 30));
      Item.SubItems.Add(FmtValor(Doc.ValorTotal));
      Item.SubItems.Add(StatusToStr(Doc.Status));

      case Doc.Status of
        stPendente:  Item.SubItemImages[4] := 0;
        stValidado:  Item.SubItemImages[4] := 1;
        stRejeitado: Item.SubItemImages[4] := 2;
      end;
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
  LI: TListItem;
begin
  if not Assigned(FController) then Exit;
  Doc := FController.ObterDocumento(AIndex);
  if not Assigned(Doc) then
  begin
    LimparDetalhes;
    Exit;
  end;

  lblTipoVal.Caption := TipoDocumentoToStr(Doc.Tipo);
  lblNumeroVal.Caption := Doc.Numero;
  lblEmitenteVal.Caption := Doc.NomeEmitente;
  lblCNPJEVal.Caption := FormatarCNPJ(Doc.CnpjEmitente);
  lblDestVal.Caption := Doc.NomeDestinatario;
  lblCNPJDVal.Caption := FormatarCNPJ(Doc.CnpjDestinatario);
  lblValorVal.Caption := 'R$ ' + FmtValor(Doc.ValorTotal);
  lblStatusVal.Caption := StatusToStr(Doc.Status);

  case Doc.Status of
    stPendente:  begin ShapeStatus.Brush.Color := COR_PENDENTE; lblStatusVal.Font.Color := clNavy; end;
    stValidado:  begin ShapeStatus.Brush.Color := COR_VALIDADO; lblStatusVal.Font.Color := clGreen; end;
    stRejeitado: begin ShapeStatus.Brush.Color := COR_REJEITADO; lblStatusVal.Font.Color := clMaroon; end;
    stErro:      begin ShapeStatus.Brush.Color := clRed; lblStatusVal.Font.Color := clRed; end;
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
      LI.SubItems.Add(FmtValor(Item.ValorUnitario));
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
  if Assigned(lvDocs.Selected) then
    Result := lvDocs.Selected.Index
  else
    Result := -1;
end;

procedure TfrmMain.lvDocsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and Assigned(Item) then
    MostrarDetalhes(Item.Index);
end;

procedure TfrmMain.btnAtualizarClick(Sender: TObject);
begin
  if not Assigned(FController) then Exit;
  FController.CarregarDocumentos;
  AtualizarLista;
  AtualizarStatus('Lista atualizada.');
end;

procedure TfrmMain.btnValidarClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := ObterIdSelecionado;
  if Id = 0 then begin AtualizarStatus('Selecione um documento.'); Exit; end;
  FController.ValidarDocumento(Id);
  btnAtualizarClick(Self);
end;

procedure TfrmMain.btnCalcularClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := ObterIdSelecionado;
  if Id = 0 then begin AtualizarStatus('Selecione um documento.'); Exit; end;
  FController.CalcularImpostos(Id);
  AtualizarStatus(Format('ICMS calculado - doc #%d.', [Id]));
end;

procedure TfrmMain.btnAnalisarIAClick(Sender: TObject);
var
  Id, Idx: Integer;
  Doc: TFiscalDocument;
begin
  Id := ObterIdSelecionado;
  if Id = 0 then begin AtualizarStatus('Selecione um documento.'); Exit; end;

  Idx := ObterIndexSelecionado;
  Doc := FController.ObterDocumento(Idx);
  if not Assigned(Doc) then Exit;

  memIA.Clear;
  memIA.Lines.Add(Format('Documento: %s #%s - %s', [TipoDocumentoToStr(Doc.Tipo), Doc.Numero, Doc.NomeEmitente]));
  memIA.Lines.Add(Format('Valor: R$ %s | Itens: %d', [FmtValor(Doc.ValorTotal), Doc.Itens.Count]));
  memIA.Lines.Add(Format('CNPJ Emitente: %s', [FormatarCNPJ(Doc.CnpjEmitente)]));
  memIA.Lines.Add('');
  memIA.Lines.Add('Enviando para DeepSeek...');
  memIA.Update;

  pcLog.ActivePage := tsIA;
  FController.AnalisarComIA(Id);

  memIA.Lines.Add('');
  memIA.Lines.Add(Format('Modelo: %s', [FController.ObterUltimoResultadoIA.Modelo]));
  memIA.Lines.Add(Format('Anomalias encontradas: %d', [FController.ObterUltimoResultadoIA.AnomaliasEncontradas]));
  memIA.Lines.Add(Format('Confianca: %.0f%%', [FController.ObterUltimoResultadoIA.Confianca * 100]));
  if FController.ObterUltimoResultadoIA.Resposta <> '' then
  begin
    memIA.Lines.Add('');
    memIA.Lines.Add('Resposta:');
    memIA.Lines.Add(FController.ObterUltimoResultadoIA.Resposta);
  end;
  AtualizarStatus(Format('IA: %d anomalia(s) (confianca %.0f%%)',
    [FController.ObterUltimoResultadoIA.AnomaliasEncontradas, FController.ObterUltimoResultadoIA.Confianca * 100]));
end;

procedure TfrmMain.btnImportarClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  if not Assigned(FController) then Exit;
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := 'Importar XML Fiscal';
    Dlg.Filter := 'XML (*.xml)|*.xml';
    Dlg.InitialDir := ExtractFilePath(ParamStr(0)) + '..\..\..\..\docs\xml-exemplos';
    if Dlg.Execute then
    begin
      FController.ImportarXml(Dlg.FileName);
      btnAtualizarClick(Self);
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
      btnAtualizarClick(Self);
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
  if MessageDlg(Format('Excluir documento #%d?', [Id]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FController.ExcluirDocumento(Id);
    btnAtualizarClick(Self);
  end;
end;

end.
