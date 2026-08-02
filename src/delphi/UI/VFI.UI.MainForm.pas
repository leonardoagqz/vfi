unit VFI.UI.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.Menus,
  VFI.Domain.Interfaces, VFI.Domain.Entities, VFI.Domain.Enums;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel; lblTitle: TLabel; lblSub: TLabel; lblCount: TLabel;
    pnlToolbar: TPanel;
    btnImportar: TSpeedButton; btnExcluir: TSpeedButton; btnAnalisarIA: TSpeedButton;
    Splitter1: TSplitter;
    pnlLeft: TPanel; lvDocs: TListView;
    pnlRight: TPanel;
    gbDetalhes: TGroupBox;
    lblTipo: TLabel; lblTipoVal: TLabel; lblNumero: TLabel; lblNumeroVal: TLabel;
    lblEmitente: TLabel; lblEmitenteVal: TLabel; lblCNPJE: TLabel; lblCNPJEVal: TLabel;
    lblDest: TLabel; lblDestVal: TLabel; lblCNPJD: TLabel; lblCNPJDVal: TLabel;
    lblValor: TLabel; lblValorVal: TLabel; lblStatus: TLabel; lblStatusVal: TLabel;
    ShapeStatus: TShape;
    pnlValidacao: TPanel; lblValidacaoTitulo: TLabel; memValidacao: TMemo;
    pcDetalhes: TPageControl;
    tsImpostos: TTabSheet; lvImpostos: TListView;
    tsItens: TTabSheet; lvItens: TListView;
    tsAnaliseIA: TTabSheet; memResultadoIA: TMemo;
    pnlBottom: TPanel; memLog: TMemo;
    pnlStatus: TPanel; lblStatusMsg: TLabel;
    PopupImportar: TPopupMenu; miImportarUm: TMenuItem; miImportarVarios: TMenuItem;
    PopupExcluir: TPopupMenu; miExcluirSelecionado: TMenuItem; miLimparTudo: TMenuItem;
    procedure FormCreate(Sender: TObject); procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnImportarClick(Sender: TObject);
    procedure miImportarUmClick(Sender: TObject); procedure miImportarVariosClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure miExcluirSelecionadoClick(Sender: TObject); procedure miLimparTudoClick(Sender: TObject);
    procedure btnAnalisarIAClick(Sender: TObject);
    procedure lvDocsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    FController: IMainController;
    procedure MostrarDetalhes(const AIndex: Integer); procedure LimparDetalhes;
    function ObterIdSelecionado: Integer; function ObterIndexSelecionado: Integer;
  public
    procedure AtualizarStatus(const AMsg: string); procedure AtualizarTela;
    property Controller: IMainController read FController write FController;
  end;

var
  frmMain: TfrmMain;

implementation
{$R *.dfm}
uses VFI.AppModule;

function FormatarCNPJ(const S: string): string;
begin
  Result := Trim(S);
  if Length(Result)=14 then Result:=Copy(Result,1,2)+'.'+Copy(Result,3,3)+'.'+Copy(Result,6,3)+'/'+Copy(Result,9,4)+'-'+Copy(Result,13,2);
end;

function FmtValor(const V: Currency): string; begin Result:=FormatFloat('#,##0.00',V); end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  KeyPreview:=True; DoubleBuffered:=True;
  lvDocs.ViewStyle:=vsReport; lvDocs.RowSelect:=True; lvDocs.GridLines:=True;
  lvDocs.Columns.Add.Caption:='ID'; lvDocs.Columns[0].Width:=38;
  lvDocs.Columns.Add.Caption:='Tipo'; lvDocs.Columns[1].Width:=44;
  lvDocs.Columns.Add.Caption:='Numero'; lvDocs.Columns[2].Width:=60;
  lvDocs.Columns.Add.Caption:='Emitente'; lvDocs.Columns[3].Width:=240;
  lvDocs.Columns.Add.Caption:='Valor (R$)'; lvDocs.Columns[4].Width:=100;
  lvDocs.Columns.Add.Caption:='Status'; lvDocs.Columns[5].Width:=85;
  lvImpostos.ViewStyle:=vsReport; lvImpostos.RowSelect:=True; lvImpostos.GridLines:=True;
  lvImpostos.Columns.Add.Caption:='Imposto'; lvImpostos.Columns[0].Width:=65;
  lvImpostos.Columns.Add.Caption:='Base Calculo'; lvImpostos.Columns[1].Width:=100;
  lvImpostos.Columns.Add.Caption:='Aliquota'; lvImpostos.Columns[2].Width:=65;
  lvImpostos.Columns.Add.Caption:='Valor'; lvImpostos.Columns[3].Width:=100;
  lvImpostos.Columns.Add.Caption:='CST'; lvImpostos.Columns[4].Width:=45;
  lvItens.ViewStyle:=vsReport; lvItens.RowSelect:=True; lvItens.GridLines:=True;
  lvItens.Columns.Add.Caption:='Codigo'; lvItens.Columns[0].Width:=70;
  lvItens.Columns.Add.Caption:='Descricao'; lvItens.Columns[1].Width:=200;
  lvItens.Columns.Add.Caption:='Qtd'; lvItens.Columns[2].Width:=50;
  lvItens.Columns.Add.Caption:='Vlr Unit'; lvItens.Columns[3].Width:=80;
  lvItens.Columns.Add.Caption:='Vlr Total'; lvItens.Columns[4].Width:=90;
  lvItens.Columns.Add.Caption:='NCM'; lvItens.Columns[5].Width:=70;
  lvItens.Columns.Add.Caption:='CFOP'; lvItens.Columns[6].Width:=55;
  memResultadoIA.Font.Name:='Consolas'; memResultadoIA.Font.Size:=10;
  pcDetalhes.ActivePage:=tsItens;
  LimparDetalhes;
  AtualizarStatus('Pronto. Use Importar para carregar XMLs fiscais.');
end;

procedure TfrmMain.FormDestroy(Sender: TObject); begin FController:=nil; end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift=[ssCtrl] then case Key of
    Ord('I'): miImportarUmClick(Self); Ord('A'): btnAnalisarIAClick(Self); end
  else if Key=VK_DELETE then miExcluirSelecionadoClick(Self);
end;

procedure TfrmMain.AtualizarStatus(const AMsg: string);
begin lblStatusMsg.Caption:=AMsg; memLog.Lines.Add(FormatDateTime('hh:nn:ss',Now)+'  '+AMsg); end;

procedure TfrmMain.LimparDetalhes;
begin
  lblTipoVal.Caption:='-'; lblNumeroVal.Caption:='-'; lblEmitenteVal.Caption:='-';
  lblCNPJEVal.Caption:='-'; lblDestVal.Caption:='-'; lblCNPJDVal.Caption:='-';
  lblValorVal.Caption:='-'; lblStatusVal.Caption:='-';
  ShapeStatus.Brush.Color:=clBtnFace; lblStatusVal.Font.Color:=clWindowText;
  lblValidacaoTitulo.Caption:=''; lblValidacaoTitulo.Font.Color:=clWindowText;
  pnlValidacao.Color:=clBtnFace; memValidacao.Clear;
  lvImpostos.Items.Clear; lvItens.Items.Clear; memResultadoIA.Clear;
  tsImpostos.Caption:='Impostos'; tsItens.Caption:='Itens';
end;

procedure TfrmMain.AtualizarTela;
var i,Qtd: Integer; Doc: TFiscalDocument; LI: TListItem;
begin
  if not Assigned(FController) then Exit;
  FController.CarregarDocumentos; Qtd:=FController.QuantidadeDocumentos;
  lblCount.Caption:=Format('%d documento(s)',[Qtd]);
  lvDocs.Items.BeginUpdate;
  try
    lvDocs.Items.Clear;
    for i:=0 to Qtd-1 do begin
      Doc:=FController.ObterDocumento(i); if not Assigned(Doc) then Continue;
      LI:=lvDocs.Items.Add; LI.Caption:=IntToStr(Doc.Id);
      LI.SubItems.Add(TipoDocumentoToStr(Doc.Tipo)); LI.SubItems.Add(Doc.Numero);
      LI.SubItems.Add(Copy(Doc.NomeEmitente,1,35)); LI.SubItems.Add(FmtValor(Doc.ValorTotal));
      LI.SubItems.Add(StatusToStr(Doc.Status));
    end;
  finally lvDocs.Items.EndUpdate; end;
  if lvDocs.Items.Count>0 then begin lvDocs.Selected:=lvDocs.Items[0]; lvDocs.ItemFocused:=lvDocs.Items[0]; MostrarDetalhes(0); end
  else LimparDetalhes;
end;

procedure TfrmMain.MostrarDetalhes(const AIndex: Integer);
var Doc: TFiscalDocument; i: Integer; Item: TDocumentItem; Calc: TTaxCalculation; LI: TListItem; Val: TResultadoValidacao;
begin
  if not Assigned(FController) then Exit;
  Doc:=FController.ObterDocumento(AIndex); if not Assigned(Doc) then begin LimparDetalhes; Exit; end;
  lblTipoVal.Caption:=TipoDocumentoToStr(Doc.Tipo); lblNumeroVal.Caption:=Doc.Numero;
  lblEmitenteVal.Caption:=Doc.NomeEmitente; lblCNPJEVal.Caption:=FormatarCNPJ(Doc.CnpjEmitente);
  lblDestVal.Caption:=Doc.NomeDestinatario; lblCNPJDVal.Caption:=FormatarCNPJ(Doc.CnpjDestinatario);
  lblValorVal.Caption:='R$ '+FmtValor(Doc.ValorTotal); lblStatusVal.Caption:=StatusToStr(Doc.Status);
  case Doc.Status of
    stPendente:  begin ShapeStatus.Brush.Color:=$004090FF; lblStatusVal.Font.Color:=clNavy; end;
    stValidado:  begin ShapeStatus.Brush.Color:=$0040B840; lblStatusVal.Font.Color:=clGreen; end;
    stRejeitado: begin ShapeStatus.Brush.Color:=$004040F0; lblStatusVal.Font.Color:=clMaroon; end;
  end;

  Val:=TAppModule.Validator.ValidarDocumento(Doc);
  if Val.IsValid then begin
    lblValidacaoTitulo.Caption:='APROVADO - Todos os campos fiscais validos';
    lblValidacaoTitulo.Font.Color:=clGreen; pnlValidacao.Color:=$00E0FFE0;
    memValidacao.Clear; memValidacao.Lines.Add('CNPJ, NCM, CFOP e chave fiscal corretos.');
  end else begin
    lblValidacaoTitulo.Caption:=Format('REPROVADO - %d problema(s) encontrado(s)',[Val.Erros.Count]);
    lblValidacaoTitulo.Font.Color:=clMaroon; pnlValidacao.Color:=$00E0E0FF;
    memValidacao.Clear;
    for i:=0 to Val.Erros.Count-1 do memValidacao.Lines.Add(Val.Erros[i]);
  end;

  tsImpostos.Caption:=Format('Impostos (%d)',[Doc.Calculos.Count]);
  lvImpostos.Items.BeginUpdate;
  try
    lvImpostos.Items.Clear;
    for i:=0 to Doc.Calculos.Count-1 do begin
      Calc:=Doc.Calculos[i]; LI:=lvImpostos.Items.Add; LI.Caption:=ImpostoToStr(Calc.TipoImposto);
      LI.SubItems.Add(FmtValor(Calc.BaseCalculo)); LI.SubItems.Add(FormatFloat('0.##',Calc.Aliquota)+'%');
      LI.SubItems.Add(FmtValor(Calc.ValorImposto)); LI.SubItems.Add(Calc.CST);
    end;
  finally lvImpostos.Items.EndUpdate; end;

  tsItens.Caption:=Format('Itens (%d)',[Doc.Itens.Count]);
  lvItens.Items.BeginUpdate;
  try
    lvItens.Items.Clear;
    for i:=0 to Doc.Itens.Count-1 do begin
      Item:=Doc.Itens[i]; LI:=lvItens.Items.Add; LI.Caption:=Item.CodigoProduto;
      LI.SubItems.Add(Item.NomeProduto); LI.SubItems.Add(FormatFloat('0.####',Item.Quantidade));
      LI.SubItems.Add(FmtValor(Item.ValorUnitario)); LI.SubItems.Add(FmtValor(Item.ValorTotal));
      LI.SubItems.Add(Item.NCM); LI.SubItems.Add(Item.CFOP);
    end;
  finally lvItens.Items.EndUpdate; end;
end;

function TfrmMain.ObterIdSelecionado: Integer; begin if Assigned(lvDocs.Selected) then Result:=StrToIntDef(lvDocs.Selected.Caption,0) else Result:=0; end;
function TfrmMain.ObterIndexSelecionado: Integer; begin if Assigned(lvDocs.Selected) then Result:=lvDocs.Selected.Index else Result:=-1; end;
procedure TfrmMain.lvDocsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean); begin if Selected and Assigned(Item) then MostrarDetalhes(Item.Index); end;
procedure TfrmMain.btnImportarClick(Sender: TObject); var Pt:TPoint; begin Pt:=btnImportar.ClientToScreen(Point(0,btnImportar.Height)); PopupImportar.Popup(Pt.X,Pt.Y); end;

procedure TfrmMain.miImportarUmClick(Sender: TObject);
var Dlg:TOpenDialog;
begin if not Assigned(FController) then Exit;
  Dlg:=TOpenDialog.Create(Self);
  try Dlg.Title:='Importar XML Fiscal (NFe/CTe)'; Dlg.Filter:='XML (*.xml)|*.xml';
    Dlg.InitialDir:=ExtractFilePath(ParamStr(0))+'..\..\..\..\docs\xml-exemplos';
    if Dlg.Execute then begin FController.ImportarXml(Dlg.FileName); AtualizarTela; end;
  finally Dlg.Free; end;
end;

procedure TfrmMain.miImportarVariosClick(Sender: TObject);
var Dlg:TOpenDialog; i:Integer; Arqs:TArray<string>;
begin if not Assigned(FController) then Exit;
  Dlg:=TOpenDialog.Create(Self);
  try Dlg.Title:='Importar Varios XMLs'; Dlg.Filter:='XML (*.xml)|*.xml';
    Dlg.Options:=[ofAllowMultiSelect,ofFileMustExist];
    Dlg.InitialDir:=ExtractFilePath(ParamStr(0))+'..\..\..\..\docs\xml-exemplos';
    if Dlg.Execute then begin
      SetLength(Arqs,Dlg.Files.Count); for i:=0 to Dlg.Files.Count-1 do Arqs[i]:=Dlg.Files[i];
      FController.ImportarMultiplosXmls(Arqs); AtualizarTela;
    end;
  finally Dlg.Free; end;
end;

procedure TfrmMain.btnExcluirClick(Sender: TObject); var Pt:TPoint; begin Pt:=btnExcluir.ClientToScreen(Point(0,btnExcluir.Height)); PopupExcluir.Popup(Pt.X,Pt.Y); end;

procedure TfrmMain.miExcluirSelecionadoClick(Sender: TObject);
var Id:Integer;
begin Id:=ObterIdSelecionado; if Id=0 then begin AtualizarStatus('Selecione um documento.'); Exit; end;
  if MessageDlg(Format('Excluir documento #%d?',[Id]),mtConfirmation,[mbYes,mbNo],0)=mrYes then begin
    FController.ExcluirDocumento(Id); AtualizarTela; memLog.Clear; memResultadoIA.Clear;
    AtualizarStatus(Format('Documento #%d excluido.',[Id])); end;
end;

procedure TfrmMain.miLimparTudoClick(Sender: TObject);
begin if MessageDlg('Excluir TODOS os documentos?',mtWarning,[mbYes,mbNo],0)=mrYes then begin
    while FController.QuantidadeDocumentos>0 do FController.ExcluirDocumento(FController.ObterDocumento(0).Id);
    AtualizarTela; memLog.Clear; memResultadoIA.Clear; AtualizarStatus('Todos os documentos excluidos.'); end;
end;

procedure TfrmMain.btnAnalisarIAClick(Sender: TObject);
var Id,Idx:Integer; Doc:TFiscalDocument; R:TResultadoIA;
begin Id:=ObterIdSelecionado; if Id=0 then begin AtualizarStatus('Selecione um documento.'); Exit; end;
  Idx:=ObterIndexSelecionado; Doc:=FController.ObterDocumento(Idx); if not Assigned(Doc) then Exit;

  memResultadoIA.Clear;
  memResultadoIA.Lines.Add(Format('Documento: %s #%s | R$ %s | %d itens | %d impostos',
    [TipoDocumentoToStr(Doc.Tipo),Doc.Numero,FmtValor(Doc.ValorTotal),Doc.Itens.Count,Doc.Calculos.Count]));
  memResultadoIA.Lines.Add(Format('Emitente: %s (CNPJ: %s)',[Doc.NomeEmitente,FormatarCNPJ(Doc.CnpjEmitente)]));
  memResultadoIA.Lines.Add('');

  pcDetalhes.ActivePage:=tsAnaliseIA;
  Application.ProcessMessages;

  FController.AnalisarComIA(Id); R:=FController.ObterUltimoResultadoIA;

  memResultadoIA.Lines.Add(Format('Modelo: %s | Anomalias: %d | Confianca: %.0f%%',[R.Modelo,R.AnomaliasEncontradas,R.Confianca*100]));
  memResultadoIA.Lines.Add('');
  if R.Resposta<>'' then memResultadoIA.Lines.Add(R.Resposta) else memResultadoIA.Lines.Add('[Chave API nao configurada - usando analise local]');
end;

end.
