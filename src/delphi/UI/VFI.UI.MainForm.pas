unit VFI.UI.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, System.IOUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.Menus,
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
    tsRegras: TTabSheet; memRegrasFiscais: TMemo; pnlRegrasBotoes: TPanel;
    btnAddRegra: TButton; btnDelRegra: TButton;
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
    procedure btnAddRegraClick(Sender: TObject);
    procedure btnDelRegraClick(Sender: TObject);
    procedure lvDocsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure memRegrasFiscaisChange(Sender: TObject);
  private
    FController: IMainController;
    procedure MostrarDetalhes(const AIndex: Integer); procedure LimparDetalhes;
    procedure LimparLogs;
    procedure AtualizarValidacaoSelecionada(const ADoc: TFiscalDocument);
    procedure CarregarRegrasPadrao;
    procedure SalvarRegrasFiscais;
    procedure NotificarRegrasAlteradas;
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
  memRegrasFiscais.Font.Name:='Consolas'; memRegrasFiscais.Font.Size:=10;
  CarregarRegrasPadrao;
  pcDetalhes.ActivePage:=tsItens; pcBottom.ActivePage:=tsLog;
  LimparDetalhes;
  AtualizarStatus('Pronto. Use Importar para carregar XMLs fiscais.');
end;

function TfrmMain.ObterRegrasFiscais: string;
begin
  Result := memRegrasFiscais.Lines.Text;
end;

procedure TfrmMain.memRegrasFiscaisChange(Sender: TObject);
begin
  if Assigned(FController) then
  begin
    FController.SetRegrasFiscais(memRegrasFiscais.Lines.Text);
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
  if memRegrasFiscais.Lines.Count > 0 then
    memResultadoIA.Lines.Add(Format('Regras de referencia: %d linha(s) carregada(s)', [memRegrasFiscais.Lines.Count]));
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
    memRegrasFiscais.Lines.LoadFromFile(Caminho);
    AtualizarStatus(Format('Regras fiscais carregadas: %s (%d linhas)', [ExtractFileName(Caminho), memRegrasFiscais.Lines.Count]));
  end
  else
  begin
    memRegrasFiscais.Lines.Clear;
    memRegrasFiscais.Lines.Add('--- REGRAS FISCAIS DE REFERENCIA (ICMS) ---');
    memRegrasFiscais.Lines.Add('ICMS-R01: Aliquota interestadual: 7% (Sul/Sudeste p/ Sul/Sudeste), 12% (demais)');
    memRegrasFiscais.Lines.Add('ICMS-R02: Aliquota interna SP/RJ/MG: 18%, RS: 17%, PR: 18%');
    memRegrasFiscais.Lines.Add('ICMS-R03: NCM 8528 (monitores): ST obrigatoria SP (Protocolo ICMS)');
    memRegrasFiscais.Lines.Add('ICMS-R04: NCM 8471 (notebooks/computadores): ST obrigatoria SP, MG, PR');
    memRegrasFiscais.Lines.Add('ICMS-R05: NCM 8443 (toners/impressoras): ST em SP');
    memRegrasFiscais.Lines.Add('ICMS-R06: MVA original ST: 40% (interno), 50% (interestadual)');
    memRegrasFiscais.Lines.Add('ICMS-R07: MVA ajustado = [(1+MVA)*(1-ALQinter)/(1-ALQintra)] - 1');
    memRegrasFiscais.Lines.Add('ICMS-R08: CFOP 5101/6101: venda interestadual - ICMS interestadual');
    memRegrasFiscais.Lines.Add('ICMS-R09: CFOP 5405/6405: venda com ST interestadual - retencao origem');
    memRegrasFiscais.Lines.Add('ICMS-R10: CFOP 5403/6403: venda com ST para consumidor final');
    memRegrasFiscais.Lines.Add('ICMS-R11: ICMS sobre frete CIF: base inclui valor do frete');
    memRegrasFiscais.Lines.Add('ICMS-R12: Reducao base calculo: cesta basica (Conv. ICMS)');
    memRegrasFiscais.Lines.Add('ICMS-R13: Diferimento ICMS: produtos agricolas, sucatas, materias-primas');
    memRegrasFiscais.Lines.Add('ICMS-R14: Isencao ICMS: exportacao (CFOP 7xxx), livros, jornais');
    memRegrasFiscais.Lines.Add('ICMS-R15: Creditos ICMS: insumos, ativo fixo (CIAP 1/48), energia');
    memRegrasFiscais.Lines.Add('ICMS-R16: Estorno credito: saida isenta exige estorno proporcional');
    memRegrasFiscais.Lines.Add('ICMS-R17: NF-e > R$100k: obrigatoria MDF-e vinculado');
    memRegrasFiscais.Lines.Add('ICMS-R18: Prazo cancelamento NF-e: 24h (alguns estados: 480h)');
    memRegrasFiscais.Lines.Add('ICMS-R19: Carta Correcao Eletronica (CC-e): corrige dados nao fiscais');
    memRegrasFiscais.Lines.Add('ICMS-R20: Simples Nacional: aliquotas unificadas, nao gera credito ICMS');
    memRegrasFiscais.Lines.Add('');
    memRegrasFiscais.Lines.Add('--- REGRAS FISCAIS DE REFERENCIA (IPI) ---');
    memRegrasFiscais.Lines.Add('IPI-R01: NCM 8471 (computadores/notebooks): IPI 0% (Lei do Bem)');
    memRegrasFiscais.Lines.Add('IPI-R02: NCM 8528 (monitores): IPI variavel conforme TIPI');
    memRegrasFiscais.Lines.Add('IPI-R03: NCM 8443 (impressoras/toners): IPI 0-5%');
    memRegrasFiscais.Lines.Add('IPI-R04: NCM 8534 (circuitos impressos): IPI 0%');
    memRegrasFiscais.Lines.Add('IPI-R05: NCM 4802 (papel): IPI 0% imprensa, 5% outros');
    memRegrasFiscais.Lines.Add('IPI-R06: IPI nao cumulativo: creditos para insumos industriais');
    memRegrasFiscais.Lines.Add('IPI-R07: Estabelecimento comercial: nao destaca IPI');
    memRegrasFiscais.Lines.Add('IPI-R08: Suspensao IPI: insumos destinados a exportacao');
    memRegrasFiscais.Lines.Add('IPI-R09: CST IPI: 50=tributado, 51=suspenso, 52=isento, 53=nao trib');
    memRegrasFiscais.Lines.Add('');
    memRegrasFiscais.Lines.Add('--- REGRAS FISCAIS DE REFERENCIA (PIS/COFINS) ---');
    memRegrasFiscais.Lines.Add('PCO-R01: Lucro Real: PIS 1.65%, COFINS 7.6% (nao-cumulativo)');
    memRegrasFiscais.Lines.Add('PCO-R02: Lucro Presumido: PIS 0.65%, COFINS 3.0% (cumulativo)');
    memRegrasFiscais.Lines.Add('PCO-R03: Creditos nao-cumulativo: insumos, energia, alugueis, deprec');
    memRegrasFiscais.Lines.Add('PCO-R04: Conceito insumo (STJ): essencial e relevante para atividade');
    memRegrasFiscais.Lines.Add('PCO-R05: Monofasico: combustiveis, medicamentos, cosmeticos, aguas');
    memRegrasFiscais.Lines.Add('PCO-R06: PIS/COFINS importacao: devido na entrada de bens estrangeiros');
    memRegrasFiscais.Lines.Add('PCO-R07: CST PIS/COFINS: 01=tributado, 04=monofasico, 06=aliquota zero');
    memRegrasFiscais.Lines.Add('PCO-R08: Simples: recolhe PIS/COFINS na aliquota unificada');
    memRegrasFiscais.Lines.Add('PCO-R09: Retencao na fonte: 4.65% sobre servicos (IN SRF 459/2004)');
    memRegrasFiscais.Lines.Add('PCO-R10: Exclusao ICMS base PIS/COFINS: tese do seculo (STF)');
    memRegrasFiscais.Lines.Add('');
    memRegrasFiscais.Lines.Add('--- REGRAS FISCAIS DE REFERENCIA (CFOP) ---');
    memRegrasFiscais.Lines.Add('CFOP-R01: 1xxx=entrada estadual, 2xxx=entrada interest, 3xxx=entrada ext');
    memRegrasFiscais.Lines.Add('CFOP-R02: 5xxx=saida estadual, 6xxx=saida interestadual, 7xxx=saida ext');
    memRegrasFiscais.Lines.Add('CFOP-R03: 5101/6101: venda producao propria ou mercadoria adquirida');
    memRegrasFiscais.Lines.Add('CFOP-R04: 5351/6351: prestacao servico transporte (CT-e)');
    memRegrasFiscais.Lines.Add('CFOP-R05: 5405/6405: venda com ST - usar qdo ha protocolo ICMS-ST');
    memRegrasFiscais.Lines.Add('CFOP-R06: 5949/6949: outras saidas - nao usar para operacoes comuns');
    memRegrasFiscais.Lines.Add('CFOP-R07: 5910/6910: remessa para industrializacao');
    memRegrasFiscais.Lines.Add('CFOP-R08: 5929/6929: remessa para demonstracao (suspensao ICMS)');
    memRegrasFiscais.Lines.Add('CFOP-R09: CFOP de entrada (1xxx/2xxx/3xxx): nao usar em NF-e de saida');
    memRegrasFiscais.Lines.Add('');
    memRegrasFiscais.Lines.Add('--- REGRAS FISCAIS DE REFERENCIA (NCM) ---');
    memRegrasFiscais.Lines.Add('NCM-R01: 00000000: invalido - deve ter 8 digitos validos');
    memRegrasFiscais.Lines.Add('NCM-R02: 85xxxxxx: maquinas, aparelhos e materiais eletricos');
    memRegrasFiscais.Lines.Add('NCM-R03: 84xxxxxx: reatores, caldeiras, maquinas, aparelhos mecanicos');
    memRegrasFiscais.Lines.Add('NCM-R04: 48xxxxxx: papel e cartao - possivel incidencia adicional');
    memRegrasFiscais.Lines.Add('NCM-R05: NCM 8528.52.20: monitores video - ST SP, MG');
    memRegrasFiscais.Lines.Add('NCM-R06: NCM 8471.30.12: notebooks - ST varios estados, IPI 0%');
    memRegrasFiscais.Lines.Add('NCM-R07: NCM 8443.99.33: toners - ST SP');
    memRegrasFiscais.Lines.Add('NCM-R08: NCM 8534.00.00: circuitos impressos - IPI 0%, ICMS 12% SP');
    memRegrasFiscais.Lines.Add('');
    memRegrasFiscais.Lines.Add('--- REGRAS FISCAIS DE REFERENCIA (VALIDACAO) ---');
    memRegrasFiscais.Lines.Add('VAL-R01: Soma itens NF-e deve coincidir com valor total (vNF)');
    memRegrasFiscais.Lines.Add('VAL-R02: CNPJ: 14 digitos obrigatorios com DV modulo 11');
    memRegrasFiscais.Lines.Add('VAL-R03: NCM: 8 digitos obrigatorios, nao aceitar 00000000');
    memRegrasFiscais.Lines.Add('VAL-R04: CFOP: 4 digitos entre 1000 e 7999');
    memRegrasFiscais.Lines.Add('VAL-R05: Chave NFe: 44 digitos com DV calculado modulo 11');
    memRegrasFiscais.Lines.Add('VAL-R06: CST 00 (tributado): vBC>0 e vICMS>0 obrigatoriamente');
    memRegrasFiscais.Lines.Add('VAL-R07: CST 40/41/50 (isento/nao trib/suspenso): vICMS=0 obrigatorio');
    memRegrasFiscais.Lines.Add('VAL-R08: CFOP compativel com tipo operacao (entrada/saida)');
    memRegrasFiscais.Lines.Add('VAL-R09: NCM deve existir na TIPI vigente e ter 8 digitos');
    memRegrasFiscais.Lines.Add('VAL-R10: Base ICMS total (vBC) <= valor produtos (vProd)');
    memRegrasFiscais.Lines.Add('VAL-R11: NF-e sem tag <imposto>: documento incompleto');
    memRegrasFiscais.Lines.Add('VAL-R12: Emitente e destinatario com mesmo CNPJ: suspeito');
    memRegrasFiscais.Lines.Add('');
    memRegrasFiscais.Lines.Add('--- REGRAS FISCAIS DE REFERENCIA (LIMIARES) ---');
    memRegrasFiscais.Lines.Add('LIM-R01: NF-e > R$50k: verificar obrigatoriedade MDF-e');
    memRegrasFiscais.Lines.Add('LIM-R02: NF-e > R$100k: acompanhamento fiscal especial');
    memRegrasFiscais.Lines.Add('LIM-R03: Valor unitario > R$10k: verificar NCM e aliquota');
    memRegrasFiscais.Lines.Add('LIM-R04: Documento > 1 ano: verificar prescricao (5 anos)');
    memRegrasFiscais.Lines.Add('LIM-R05: DIFAL partilha 2024: 60% destino, 40% origem');
    memRegrasFiscais.Lines.Add('LIM-R06: Mesmo emitente > R$200k/mes: obrigatoriedade EFD');
    memRegrasFiscais.Lines.Add('');
    memRegrasFiscais.Lines.Add('--- Editaveis - adicione ou modifique regras ---');
    memRegrasFiscais.Lines.Add('A IA usara estas regras como referencia na analise fiscal.');
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

procedure TfrmMain.NotificarRegrasAlteradas;
begin
  if Assigned(FController) then
    FController.SetRegrasFiscais(ObterRegrasFiscais);
end;

procedure TfrmMain.SalvarRegrasFiscais;
var
  Caminho: string;
begin
  try
    Caminho := ExtractFilePath(ParamStr(0)) + '..\..\Resources\' + ARQ_REGRAS_FISCAIS;
    ForceDirectories(ExtractFilePath(Caminho));
    memRegrasFiscais.Lines.SaveToFile(Caminho);
    AtualizarStatus(Format('Regras fiscais salvas em disco (%d linhas). A IA usara as regras atualizadas.', [memRegrasFiscais.Lines.Count]));
  except
    on E: Exception do
      AtualizarStatus('ERRO ao salvar regras: ' + E.Message);
  end;
end;

procedure TfrmMain.btnAddRegraClick(Sender: TObject);
var
  Codigo, Descricao: string;
begin
  Codigo := InputBox('Nova Regra Fiscal', 'Codigo da regra (ex: ICMS-R20):', '');
  if Codigo = '' then Exit;
  Descricao := InputBox('Nova Regra Fiscal', 'Descricao da regra:', '');
  memRegrasFiscais.Lines.Add(Codigo + ': ' + Descricao);
  AtualizarStatus(Format('Regra %s adicionada. Use Ctrl+S para salvar.', [Codigo]));
  NotificarRegrasAlteradas;
end;

procedure TfrmMain.btnDelRegraClick(Sender: TObject);
var
  Linha: Integer;
begin
  Linha := memRegrasFiscais.CaretPos.Y;
  if (Linha < 0) or (Linha >= memRegrasFiscais.Lines.Count) then
  begin
    AtualizarStatus('Posicione o cursor na linha a remover.');
    Exit;
  end;
  memRegrasFiscais.Lines.Delete(Linha);
  AtualizarStatus(Format('Linha %d removida. Use Ctrl+S para salvar.', [Linha + 1]));
  NotificarRegrasAlteradas;
end;

end.
