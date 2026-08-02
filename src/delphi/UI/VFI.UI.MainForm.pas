unit VFI.UI.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.Menus, Vcl.ValEdit,
  VFI.Domain.Interfaces, VFI.Domain.Entities, VFI.Domain.Enums, VFI.UI.Constantes;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel; lblTitle: TLabel; lblSub: TLabel; lblCount: TLabel;
    pnlToolbar: TPanel;
    btnImportar: TSpeedButton; btnExcluir: TSpeedButton; btnAnalisarIA: TSpeedButton;
    btnConfigurar: TSpeedButton;
    Splitter1: TSplitter;
    pnlLeft: TPanel; lvDocs: TListView;
    pnlRight: TPanel;
    gbDetalhes: TGroupBox;
    lblTipo: TLabel; lblTipoVal: TLabel; lblNumero: TLabel; lblNumeroVal: TLabel;
    lblEmitente: TLabel; lblEmitenteVal: TLabel; lblCNPJE: TLabel; lblCNPJEVal: TLabel;
    lblDest: TLabel; lblDestVal: TLabel;
    lblValor: TLabel; lblValorVal: TLabel; lblStatus: TLabel; lblStatusVal: TLabel;
    ShapeStatus: TShape;
    pcDetalhes: TPageControl;
    tsImpostos: TTabSheet; lvImpostos: TListView;
    tsItens: TTabSheet; lvItens: TListView;
    tsAnaliseIA: TTabSheet; memResultadoIA: TMemo;
    tsRegras: TTabSheet; vleRegras: TValueListEditor;
    pcBottom: TPageControl;
    tsLog: TTabSheet; memLog: TMemo;
    tsValidacoes: TTabSheet; memValidacoes: TMemo;
    pnlStatus: TPanel; lblStatusMsg: TLabel;
    PopupExcluir: TPopupMenu; miExcluirSelecionado: TMenuItem; miLimparTudo: TMenuItem;
    procedure FormCreate(Sender: TObject); procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnImportarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure miExcluirSelecionadoClick(Sender: TObject); procedure miLimparTudoClick(Sender: TObject);
    procedure btnAnalisarIAClick(Sender: TObject);
    procedure btnConfigurarClick(Sender: TObject);
    procedure lvDocsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure vleRegrasChange(Sender: TObject);
  private
    FController: IMainController;
    procedure MostrarDetalhes(const AIndex: Integer); procedure LimparDetalhes;
    procedure LimparLogs;
    procedure AtualizarValidacaoSelecionada(const ADoc: TFiscalDocument);
    procedure CarregarRegrasPadrao;
    procedure SalvarRegrasFiscais;
    function ObterIdSelecionado: Integer; function ObterIndexSelecionado: Integer;
    function ObterRegrasFiscais: string;
  public
    procedure AtualizarStatus(const AMsg: string); procedure AtualizarTela;
    property Controller: IMainController read FController write FController;
  end;

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
  lvDocs.ViewStyle:=vsReport; lvDocs.RowSelect:=True; lvDocs.GridLines:=True; lvDocs.MultiSelect:=True;
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
  vleRegras.Font.Name:='Consolas'; vleRegras.Font.Size:=10;
  CarregarRegrasPadrao;
  pcDetalhes.ActivePage:=tsItens; pcBottom.ActivePage:=tsLog;
  LimparDetalhes;
  AtualizarStatus('Pronto. Use Importar para carregar XMLs fiscais.');
end;

function TfrmMain.ObterRegrasFiscais: string;
var
  i: Integer;
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    for i := 1 to vleRegras.RowCount - 1 do
      if (vleRegras.Keys[i] <> '') or (vleRegras.Values[vleRegras.Keys[i]] <> '') then
        SB.AppendLine(vleRegras.Keys[i] + ': ' + vleRegras.Values[vleRegras.Keys[i]]);
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

procedure TfrmMain.vleRegrasChange(Sender: TObject);
begin
  if Assigned(FController) then
  begin
    FController.SetRegrasFiscais(vleRegras.Strings.Text);
    AtualizarStatus('Regras fiscais atualizadas. A IA usara as novas regras na proxima analise.');
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject); begin FController:=nil; end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift=[ssCtrl] then case Key of
    Ord('I'): btnImportarClick(Self); Ord('A'): btnAnalisarIAClick(Self);
    Ord('S'): SalvarRegrasFiscais; end
  else if Key=VK_DELETE then miExcluirSelecionadoClick(Self);
end;

procedure TfrmMain.AtualizarStatus(const AMsg: string); 
begin lblStatusMsg.Caption:=AMsg; memLog.Lines.Add(FormatDateTime('hh:nn:ss',Now)+'  '+AMsg); end;

procedure TfrmMain.LimparDetalhes;
begin
  lblTipoVal.Caption:='-'; lblNumeroVal.Caption:='-'; lblEmitenteVal.Caption:='-';
  lblCNPJEVal.Caption:='-'; lblDestVal.Caption:='-';
  lblValorVal.Caption:='-'; lblStatusVal.Caption:='-';
  ShapeStatus.Brush.Color:=clBtnFace; lblStatusVal.Font.Color:=clWindowText;
  lvImpostos.Items.Clear; lvItens.Items.Clear; memResultadoIA.Clear;
  tsImpostos.Caption:='Impostos'; tsItens.Caption:='Itens';
end;

procedure TfrmMain.LimparLogs;
begin
  memLog.Clear; memValidacoes.Clear; memResultadoIA.Clear;
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
var Doc: TFiscalDocument; i: Integer; Item: TDocumentItem; Calc: TTaxCalculation; LI: TListItem;
begin
  if not Assigned(FController) then Exit;
  Doc:=FController.ObterDocumento(AIndex); if not Assigned(Doc) then begin LimparDetalhes; Exit; end;
  lblTipoVal.Caption:=TipoDocumentoToStr(Doc.Tipo); lblNumeroVal.Caption:=Doc.Numero;
  lblEmitenteVal.Caption:=Doc.NomeEmitente; lblCNPJEVal.Caption:=FormatarCNPJ(Doc.CnpjEmitente);
  lblDestVal.Caption:=Doc.NomeDestinatario;
  lblValorVal.Caption:='R$ '+FmtValor(Doc.ValorTotal); lblStatusVal.Caption:=StatusToStr(Doc.Status);
  case Doc.Status of
    stPendente:  begin ShapeStatus.Brush.Color:=COR_STATUS_PENDENTE; lblStatusVal.Font.Color:=clNavy; end;
    stValidado:  begin ShapeStatus.Brush.Color:=COR_STATUS_VALIDADO; lblStatusVal.Font.Color:=clGreen; end;
    stRejeitado: begin ShapeStatus.Brush.Color:=COR_STATUS_REJEITADO; lblStatusVal.Font.Color:=clMaroon; end;
  end;

  tsImpostos.Caption:=Format('Impostos (%d)',[Doc.Calculos.Count]);
  lvImpostos.Items.BeginUpdate;
  try lvImpostos.Items.Clear;
    for i:=0 to Doc.Calculos.Count-1 do begin
      Calc:=Doc.Calculos[i]; LI:=lvImpostos.Items.Add; LI.Caption:=ImpostoToStr(Calc.TipoImposto);
      LI.SubItems.Add(FmtValor(Calc.BaseCalculo)); LI.SubItems.Add(FormatFloat('0.##',Calc.Aliquota)+'%');
      LI.SubItems.Add(FmtValor(Calc.ValorImposto)); LI.SubItems.Add(Calc.CST);
    end;
  finally lvImpostos.Items.EndUpdate; end;

  tsItens.Caption:=Format('Itens (%d)',[Doc.Itens.Count]);
  lvItens.Items.BeginUpdate;
  try lvItens.Items.Clear;
    for i:=0 to Doc.Itens.Count-1 do begin
      Item:=Doc.Itens[i]; LI:=lvItens.Items.Add; LI.Caption:=Item.CodigoProduto;
      LI.SubItems.Add(Item.NomeProduto); LI.SubItems.Add(FormatFloat('0.####',Item.Quantidade));
      LI.SubItems.Add(FmtValor(Item.ValorUnitario)); LI.SubItems.Add(FmtValor(Item.ValorTotal));
      LI.SubItems.Add(Item.NCM); LI.SubItems.Add(Item.CFOP);
    end;
  finally lvItens.Items.EndUpdate; end;

  AtualizarValidacaoSelecionada(Doc);
end;

procedure TfrmMain.AtualizarValidacaoSelecionada(const ADoc: TFiscalDocument);
var Val: TResultadoValidacao; Resumo: string;
begin
  Val := FController.ValidarDocumentoAtual(ADoc);
  memValidacoes.Clear;
  memValidacoes.Lines.Add('=== DOCUMENTO SELECIONADO ===');
  memValidacoes.Lines.Add(Format('#%d  %s  %s  %s  R$ %s',
    [ADoc.Id, TipoDocumentoToStr(ADoc.Tipo), ADoc.Numero, ADoc.NomeEmitente, FmtValor(ADoc.ValorTotal)]));
  memValidacoes.Lines.Add('');
  memValidacoes.Lines.Add('--- REGRAS DO SISTEMA (obrigatorias - bloqueiam o fluxo) ---');
  if Val.IsValid then
    memValidacoes.Lines.Add('[APROVADO] CNPJ, NCM, CFOP e chave fiscal corretos.')
  else
    for var j := 0 to Val.Erros.Count - 1 do
      memValidacoes.Lines.Add('[ERRO] ' + Val.Erros[j]);

  if ADoc.Itens.Count = 0 then
    Resumo := 'sem itens'
  else
    Resumo := Format('%d itens', [ADoc.Itens.Count]);
  memValidacoes.Lines.Add(Format('[INFO] Tipo: %s | Valor: R$ %s | Itens: %s | Impostos extraidos: %d',
    [TipoDocumentoToStr(ADoc.Tipo), FmtValor(ADoc.ValorTotal), Resumo, ADoc.Calculos.Count]));
  memValidacoes.Lines.Add('');
  memValidacoes.Lines.Add('[REGRA] Validacao automatica = regras fiscais obrigatorias');
  memValidacoes.Lines.Add('[IA]    Analise IA = sugestoes baseadas em padroes e regras de referencia (nao bloqueiam)');
end;

function TfrmMain.ObterIdSelecionado: Integer; begin if Assigned(lvDocs.Selected) then Result:=StrToIntDef(lvDocs.Selected.Caption,0) else Result:=0; end;
function TfrmMain.ObterIndexSelecionado: Integer; begin if Assigned(lvDocs.Selected) then Result:=lvDocs.Selected.Index else Result:=-1; end;
procedure TfrmMain.lvDocsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean); begin if Selected and Assigned(Item) then MostrarDetalhes(Item.Index); end;
procedure TfrmMain.btnImportarClick(Sender: TObject);
var
  Dlg: TOpenDialog;
  i: Integer;
  Arquivos: TArray<string>;
begin
  if not Assigned(FController) then Exit;
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := 'Importar XML Fiscal (NFe/CTe) - selecione 1 ou varios';
    Dlg.Filter := 'XML (*.xml)|*.xml';
    Dlg.Options := [ofAllowMultiSelect, ofFileMustExist];
    Dlg.InitialDir := ExtractFilePath(ParamStr(0)) + '..\..\..\..\' + DIR_XML_EXEMPLOS;
    if Dlg.Execute then
    begin
      if Dlg.Files.Count = 1 then
        FController.ImportarXml(Dlg.Files[0])
      else
      begin
        SetLength(Arquivos, Dlg.Files.Count);
        for i := 0 to Dlg.Files.Count - 1 do
          Arquivos[i] := Dlg.Files[i];
        FController.ImportarMultiplosXmls(Arquivos);
      end;
      AtualizarTela;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmMain.btnExcluirClick(Sender: TObject); var Pt:TPoint; begin Pt:=btnExcluir.ClientToScreen(Point(0,btnExcluir.Height)); PopupExcluir.Popup(Pt.X,Pt.Y); end;

procedure TfrmMain.miExcluirSelecionadoClick(Sender: TObject);
var i,Count,Id:Integer;
begin
  Count:=lvDocs.SelCount; if Count=0 then begin AtualizarStatus('Selecione pelo menos um documento.'); Exit; end;
  if Count=1 then begin
    Id:=StrToIntDef(lvDocs.Selected.Caption,0);
    if MessageDlg(Format('Excluir documento #%d?',[Id]),mtConfirmation,[mbYes,mbNo],0)<>mrYes then Exit;
  end else if MessageDlg(Format('Excluir %d documentos?',[Count]),mtConfirmation,[mbYes,mbNo],0)<>mrYes then Exit;
  for i:=lvDocs.Items.Count-1 downto 0 do
    if lvDocs.Items[i].Selected then begin
      Id:=StrToIntDef(lvDocs.Items[i].Caption,0);
      if Id>0 then FController.ExcluirDocumento(Id);
    end;
  AtualizarTela; LimparLogs;
  AtualizarStatus(Format('%d documento(s) excluido(s).',[Count]));
end;

procedure TfrmMain.miLimparTudoClick(Sender: TObject);
begin if MessageDlg('Excluir TODOS os documentos?',mtWarning,[mbYes,mbNo],0)=mrYes then begin
    while FController.QuantidadeDocumentos>0 do FController.ExcluirDocumento(FController.ObterDocumento(0).Id);
    AtualizarTela; LimparLogs; AtualizarStatus('Todos os documentos excluidos.'); end;
end;

procedure TfrmMain.btnAnalisarIAClick(Sender: TObject);
var Id,Idx:Integer; Doc:TFiscalDocument; R:TResultadoIA;
begin Id:=ObterIdSelecionado; if Id=0 then begin AtualizarStatus('Selecione um documento.'); Exit; end;
  Idx:=ObterIndexSelecionado; Doc:=FController.ObterDocumento(Idx); if not Assigned(Doc) then Exit;

  memResultadoIA.Clear;
  memResultadoIA.Lines.Add('=== ANALISE IA (sugestoes - nao bloqueiam o fluxo) ===');
  memResultadoIA.Lines.Add('');
  memResultadoIA.Lines.Add(Format('Documento: %s #%s | R$ %s | %d itens | %d impostos',
    [TipoDocumentoToStr(Doc.Tipo),Doc.Numero,FmtValor(Doc.ValorTotal),Doc.Itens.Count,Doc.Calculos.Count]));
  memResultadoIA.Lines.Add(Format('Emitente: %s %s',[Doc.NomeEmitente,FormatarCNPJ(Doc.CnpjEmitente)]));
  if vleRegras.Strings.Count > 0 then
    memResultadoIA.Lines.Add(Format('Regras de referencia: %d linha(s) carregada(s)', [vleRegras.Strings.Count]));
  memResultadoIA.Lines.Add('');

  pcDetalhes.ActivePage:=tsAnaliseIA; Application.ProcessMessages;

  FController.SetRegrasFiscais(ObterRegrasFiscais);
  FController.AnalisarComIA(Id); R:=FController.ObterUltimoResultadoIA;

  memResultadoIA.Lines.Add(Format('Modelo: %s | Padroes suspeitos: %d | Confianca: %.0f%%',
    [R.Modelo,R.AnomaliasEncontradas,R.Confianca*100]));
  memResultadoIA.Lines.Add('');
  if R.Resposta<>'' then memResultadoIA.Lines.Add(R.Resposta)
  else memResultadoIA.Lines.Add('[Chave API nao configurada - usando analise local]');
end;

procedure TfrmMain.CarregarRegrasPadrao;
var
  Caminho: string;
begin
  Caminho := ExtractFilePath(ParamStr(0)) + '..\..\Resources\' + ARQ_REGRAS_FISCAIS;
  if FileExists(Caminho) then
  begin
    vleRegras.Strings.LoadFromFile(Caminho);
    AtualizarStatus(Format('Regras fiscais carregadas: %s (%d linhas)', [ExtractFileName(Caminho), vleRegras.Strings.Count]));
  end
  else
  begin
    vleRegras.Strings.Clear;
    vleRegras.Strings.Add('--- REGRAS FISCAIS DE REFERENCIA (ICMS) ---');
    vleRegras.Strings.Add('ICMS-R01: Aliquota interestadual: 7% (Sul/Sudeste p/ Sul/Sudeste), 12% (demais)');
    vleRegras.Strings.Add('ICMS-R02: Aliquota interna SP/RJ/MG: 18%, RS: 17%, PR: 18%');
    vleRegras.Strings.Add('ICMS-R03: NCM 8528 (monitores): ST obrigatoria SP (Protocolo ICMS)');
    vleRegras.Strings.Add('ICMS-R04: NCM 8471 (notebooks/computadores): ST obrigatoria SP, MG, PR');
    vleRegras.Strings.Add('ICMS-R05: NCM 8443 (toners/impressoras): ST em SP');
    vleRegras.Strings.Add('ICMS-R06: MVA original ST: 40% (interno), 50% (interestadual)');
    vleRegras.Strings.Add('ICMS-R07: MVA ajustado = [(1+MVA)*(1-ALQinter)/(1-ALQintra)] - 1');
    vleRegras.Strings.Add('ICMS-R08: CFOP 5101/6101: venda interestadual - ICMS interestadual');
    vleRegras.Strings.Add('ICMS-R09: CFOP 5405/6405: venda com ST interestadual - retencao origem');
    vleRegras.Strings.Add('ICMS-R10: CFOP 5403/6403: venda com ST para consumidor final');
    vleRegras.Strings.Add('ICMS-R11: ICMS sobre frete CIF: base inclui valor do frete');
    vleRegras.Strings.Add('ICMS-R12: Reducao base calculo: cesta basica (Conv. ICMS)');
    vleRegras.Strings.Add('ICMS-R13: Diferimento ICMS: produtos agricolas, sucatas, materias-primas');
    vleRegras.Strings.Add('ICMS-R14: Isencao ICMS: exportacao (CFOP 7xxx), livros, jornais');
    vleRegras.Strings.Add('ICMS-R15: Creditos ICMS: insumos, ativo fixo (CIAP 1/48), energia');
    vleRegras.Strings.Add('ICMS-R16: Estorno credito: saida isenta exige estorno proporcional');
    vleRegras.Strings.Add('ICMS-R17: NF-e > R$100k: obrigatoria MDF-e vinculado');
    vleRegras.Strings.Add('ICMS-R18: Prazo cancelamento NF-e: 24h (alguns estados: 480h)');
    vleRegras.Strings.Add('ICMS-R19: Carta Correcao Eletronica (CC-e): corrige dados nao fiscais');
    vleRegras.Strings.Add('ICMS-R20: Simples Nacional: aliquotas unificadas, nao gera credito ICMS');
    vleRegras.Strings.Add('');
    vleRegras.Strings.Add('--- REGRAS FISCAIS DE REFERENCIA (IPI) ---');
    vleRegras.Strings.Add('IPI-R01: NCM 8471 (computadores/notebooks): IPI 0% (Lei do Bem)');
    vleRegras.Strings.Add('IPI-R02: NCM 8528 (monitores): IPI variavel conforme TIPI');
    vleRegras.Strings.Add('IPI-R03: NCM 8443 (impressoras/toners): IPI 0-5%');
    vleRegras.Strings.Add('IPI-R04: NCM 8534 (circuitos impressos): IPI 0%');
    vleRegras.Strings.Add('IPI-R05: NCM 4802 (papel): IPI 0% imprensa, 5% outros');
    vleRegras.Strings.Add('IPI-R06: IPI nao cumulativo: creditos para insumos industriais');
    vleRegras.Strings.Add('IPI-R07: Estabelecimento comercial: nao destaca IPI');
    vleRegras.Strings.Add('IPI-R08: Suspensao IPI: insumos destinados a exportacao');
    vleRegras.Strings.Add('IPI-R09: CST IPI: 50=tributado, 51=suspenso, 52=isento, 53=nao trib');
    vleRegras.Strings.Add('');
    vleRegras.Strings.Add('--- REGRAS FISCAIS DE REFERENCIA (PIS/COFINS) ---');
    vleRegras.Strings.Add('PCO-R01: Lucro Real: PIS 1.65%, COFINS 7.6% (nao-cumulativo)');
    vleRegras.Strings.Add('PCO-R02: Lucro Presumido: PIS 0.65%, COFINS 3.0% (cumulativo)');
    vleRegras.Strings.Add('PCO-R03: Creditos nao-cumulativo: insumos, energia, alugueis, deprec');
    vleRegras.Strings.Add('PCO-R04: Conceito insumo (STJ): essencial e relevante para atividade');
    vleRegras.Strings.Add('PCO-R05: Monofasico: combustiveis, medicamentos, cosmeticos, aguas');
    vleRegras.Strings.Add('PCO-R06: PIS/COFINS importacao: devido na entrada de bens estrangeiros');
    vleRegras.Strings.Add('PCO-R07: CST PIS/COFINS: 01=tributado, 04=monofasico, 06=aliquota zero');
    vleRegras.Strings.Add('PCO-R08: Simples: recolhe PIS/COFINS na aliquota unificada');
    vleRegras.Strings.Add('PCO-R09: Retencao na fonte: 4.65% sobre servicos (IN SRF 459/2004)');
    vleRegras.Strings.Add('PCO-R10: Exclusao ICMS base PIS/COFINS: tese do seculo (STF)');
    vleRegras.Strings.Add('');
    vleRegras.Strings.Add('--- REGRAS FISCAIS DE REFERENCIA (CFOP) ---');
    vleRegras.Strings.Add('CFOP-R01: 1xxx=entrada estadual, 2xxx=entrada interest, 3xxx=entrada ext');
    vleRegras.Strings.Add('CFOP-R02: 5xxx=saida estadual, 6xxx=saida interestadual, 7xxx=saida ext');
    vleRegras.Strings.Add('CFOP-R03: 5101/6101: venda producao propria ou mercadoria adquirida');
    vleRegras.Strings.Add('CFOP-R04: 5351/6351: prestacao servico transporte (CT-e)');
    vleRegras.Strings.Add('CFOP-R05: 5405/6405: venda com ST - usar qdo ha protocolo ICMS-ST');
    vleRegras.Strings.Add('CFOP-R06: 5949/6949: outras saidas - nao usar para operacoes comuns');
    vleRegras.Strings.Add('CFOP-R07: 5910/6910: remessa para industrializacao');
    vleRegras.Strings.Add('CFOP-R08: 5929/6929: remessa para demonstracao (suspensao ICMS)');
    vleRegras.Strings.Add('CFOP-R09: CFOP de entrada (1xxx/2xxx/3xxx): nao usar em NF-e de saida');
    vleRegras.Strings.Add('');
    vleRegras.Strings.Add('--- REGRAS FISCAIS DE REFERENCIA (NCM) ---');
    vleRegras.Strings.Add('NCM-R01: 00000000: invalido - deve ter 8 digitos validos');
    vleRegras.Strings.Add('NCM-R02: 85xxxxxx: maquinas, aparelhos e materiais eletricos');
    vleRegras.Strings.Add('NCM-R03: 84xxxxxx: reatores, caldeiras, maquinas, aparelhos mecanicos');
    vleRegras.Strings.Add('NCM-R04: 48xxxxxx: papel e cartao - possivel incidencia adicional');
    vleRegras.Strings.Add('NCM-R05: NCM 8528.52.20: monitores video - ST SP, MG');
    vleRegras.Strings.Add('NCM-R06: NCM 8471.30.12: notebooks - ST varios estados, IPI 0%');
    vleRegras.Strings.Add('NCM-R07: NCM 8443.99.33: toners - ST SP');
    vleRegras.Strings.Add('NCM-R08: NCM 8534.00.00: circuitos impressos - IPI 0%, ICMS 12% SP');
    vleRegras.Strings.Add('');
    vleRegras.Strings.Add('--- REGRAS FISCAIS DE REFERENCIA (VALIDACAO) ---');
    vleRegras.Strings.Add('VAL-R01: Soma itens NF-e deve coincidir com valor total (vNF)');
    vleRegras.Strings.Add('VAL-R02: CNPJ: 14 digitos obrigatorios com DV modulo 11');
    vleRegras.Strings.Add('VAL-R03: NCM: 8 digitos obrigatorios, nao aceitar 00000000');
    vleRegras.Strings.Add('VAL-R04: CFOP: 4 digitos entre 1000 e 7999');
    vleRegras.Strings.Add('VAL-R05: Chave NFe: 44 digitos com DV calculado modulo 11');
    vleRegras.Strings.Add('VAL-R06: CST 00 (tributado): vBC>0 e vICMS>0 obrigatoriamente');
    vleRegras.Strings.Add('VAL-R07: CST 40/41/50 (isento/nao trib/suspenso): vICMS=0 obrigatorio');
    vleRegras.Strings.Add('VAL-R08: CFOP compativel com tipo operacao (entrada/saida)');
    vleRegras.Strings.Add('VAL-R09: NCM deve existir na TIPI vigente e ter 8 digitos');
    vleRegras.Strings.Add('VAL-R10: Base ICMS total (vBC) <= valor produtos (vProd)');
    vleRegras.Strings.Add('VAL-R11: NF-e sem tag <imposto>: documento incompleto');
    vleRegras.Strings.Add('VAL-R12: Emitente e destinatario com mesmo CNPJ: suspeito');
    vleRegras.Strings.Add('');
    vleRegras.Strings.Add('--- REGRAS FISCAIS DE REFERENCIA (LIMIARES) ---');
    vleRegras.Strings.Add('LIM-R01: NF-e > R$50k: verificar obrigatoriedade MDF-e');
    vleRegras.Strings.Add('LIM-R02: NF-e > R$100k: acompanhamento fiscal especial');
    vleRegras.Strings.Add('LIM-R03: Valor unitario > R$10k: verificar NCM e aliquota');
    vleRegras.Strings.Add('LIM-R04: Documento > 1 ano: verificar prescricao (5 anos)');
    vleRegras.Strings.Add('LIM-R05: DIFAL partilha 2024: 60% destino, 40% origem');
    vleRegras.Strings.Add('LIM-R06: Mesmo emitente > R$200k/mes: obrigatoriedade EFD');
    vleRegras.Strings.Add('');
    vleRegras.Strings.Add('--- Editaveis - adicione ou modifique regras ---');
    vleRegras.Strings.Add('A IA usara estas regras como referencia na analise fiscal.');
    AtualizarStatus('Regras fiscais carregadas (modo inline).');
  end;
end;

procedure TfrmMain.btnConfigurarClick(Sender: TObject);
var
  ApiKey, Model, IniPath: string;
  Ini: TMemIniFile;
begin
  try
    IniPath := TAppModule.Config.FindIniPath;
    if not FileExists(IniPath) then
    begin
      ForceDirectories(ExtractFilePath(IniPath));
      TFile.WriteAllText(IniPath, '[AI]' + sLineBreak + 'ApiKey=' + sLineBreak + 'Model=deepseek-chat' + sLineBreak);
    end;

    Ini := TMemIniFile.Create(IniPath);
    try
      ApiKey := Ini.ReadString('AI', 'ApiKey', '');
      Model := Ini.ReadString('AI', 'Model', 'deepseek-chat');

      ApiKey := InputBox('Configurar DeepSeek API',
        'Cole sua chave API do DeepSeek:' + sLineBreak +
        '(obtenha em platform.deepseek.com)' + sLineBreak + sLineBreak +
        'Deixe em branco para usar analise local offline.', ApiKey);

      if ApiKey <> '' then
      begin
        Model := InputBox('Modelo DeepSeek', 'Modelo (deepseek-chat / deepseek-reasoner):', Model);
        if Model = '' then Model := 'deepseek-chat';
        Ini.WriteString('AI', 'ApiKey', ApiKey);
        Ini.WriteString('AI', 'Model', Model);
        Ini.UpdateFile;

        FController.ConfigurarAPI(ApiKey, DEEPSEEK_ENDPOINT, Model);

        AtualizarStatus(Format('API DeepSeek configurada: %s. Analise real ativada.', [Model]));
      end
      else
      begin
        Ini.WriteString('AI', 'ApiKey', '');
        Ini.UpdateFile;
        AtualizarStatus('Chave API removida. Usando analise local offline.');
      end;
    finally
      Ini.Free;
    end;
  except
    on E: Exception do
      AtualizarStatus('ERRO ao configurar API: ' + E.Message);
  end;
end;

procedure TfrmMain.SalvarRegrasFiscais;
var
  Caminho: string;
begin
  try
    Caminho := ExtractFilePath(ParamStr(0)) + '..\..\Resources\' + ARQ_REGRAS_FISCAIS;
    ForceDirectories(ExtractFilePath(Caminho));
    vleRegras.Strings.SaveToFile(Caminho);
    AtualizarStatus(Format('Regras fiscais salvas em disco (%d linhas). A IA usara as regras atualizadas.', [vleRegras.Strings.Count]));
  except
    on E: Exception do
      AtualizarStatus('ERRO ao salvar regras: ' + E.Message);
  end;
end;

end.
