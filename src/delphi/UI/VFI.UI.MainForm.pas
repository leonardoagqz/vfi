unit VFI.UI.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, System.IOUtils, System.StrUtils,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.Menus, Vcl.Grids,
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
    tsRegras: TTabSheet; sgRegras: TStringGrid;
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
    for i := 1 to sgRegras.RowCount - 1 do
      if (sgRegras.Cells[0, i] <> '') or (sgRegras.Cells[1, i] <> '') then
        SB.AppendLine(sgRegras.Cells[0, i] + ': ' + sgRegras.Cells[1, i]);
    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

procedure TfrmMain.NotificarRegrasAlteradas;
begin
  if Assigned(FController) then
  begin
    FController.SetRegrasFiscais(ObterRegrasFiscais);
    AtualizarStatus('Regras enviadas para IA. A proxima analise usara as novas regras.');
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
begin

lblStatusMsg.Caption:=AMsg; memLog.Lines.Add(FormatDateTime('hh:nn:ss',Now)+'  '+AMsg); end;

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
  if ObterRegrasFiscais <> '' then
    memResultadoIA.Lines.Add('Regras fiscais carregadas para analise.');
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
  Linhas: TStringList;
  i, p: Integer;
  Codigo, Descricao: string;
begin
  Caminho := ExtractFilePath(ParamStr(0)) + '..\..\Resources\' + ARQ_REGRAS_FISCAIS;
  Linhas := TStringList.Create;
  try
    if FileExists(Caminho) then
      Linhas.LoadFromFile(Caminho)
    else
    begin
      Linhas.Add('ICMS-R01: Aliquota interestadual: 7% (Sul/Sudeste) ou 12% (demais)');
      Linhas.Add('ICMS-R02: Aliquota interna SP/RJ/MG: 18%, RS: 17%, PR: 18%');
      Linhas.Add('ICMS-R03: NCM 8528 (monitores): ST obrigatoria SP');
      Linhas.Add('ICMS-R04: NCM 8471 (notebooks): ST obrigatoria SP, MG, PR');
      Linhas.Add('ICMS-R05: MVA padrao ST: 40% (interno), 50% (interestadual)');
      Linhas.Add('ICMS-R06: NF-e > R$100k exige MDF-e vinculado');
      Linhas.Add('ICMS-R07: CFOP 5101/6101: venda interestadual');
      Linhas.Add('ICMS-R08: CFOP 5405/6405: venda com ST interestadual');
      Linhas.Add('ICMS-R09: Simples Nacional: nao gera credito ICMS para destinatario');
      Linhas.Add('ICMS-R10: Prazo cancelamento NF-e: 24h apos autorizacao');
      Linhas.Add('IPI-R01: NCM 8471 (computadores): IPI 0% (Lei do Bem)');
      Linhas.Add('IPI-R02: NCM 8528 (monitores): IPI variavel conforme TIPI');
      Linhas.Add('IPI-R03: CST IPI: 50=tributado, 51=suspenso, 52=isento');
      Linhas.Add('PCO-R01: Lucro Real: PIS 1.65%, COFINS 7.6% (nao-cumulativo)');
      Linhas.Add('PCO-R02: Lucro Presumido: PIS 0.65%, COFINS 3.0% (cumulativo)');
      Linhas.Add('PCO-R03: CST PIS/COFINS: 01=tributado, 04=monofasico, 06=aliq zero');
      Linhas.Add('CFOP-R01: 5xxx=saida estadual, 6xxx=saida interestadual, 7xxx=exportacao');
      Linhas.Add('CFOP-R02: 5351/6351: prestacao servico transporte (CT-e)');
      Linhas.Add('NCM-R01: NCM 00000000: invalido - deve ter 8 digitos validos');
      Linhas.Add('NCM-R02: NCM 8528.52.20: monitores video - ST SP, MG');
      Linhas.Add('NCM-R03: NCM 8471.30.12: notebooks - ST varios estados');
      Linhas.Add('VAL-R01: Soma itens deve coincidir com valor total da NF-e');
      Linhas.Add('VAL-R02: CNPJ: 14 digitos obrigatorios com DV modulo 11');
      Linhas.Add('VAL-R03: NCM: 8 digitos obrigatorios, nao aceitar 00000000');
      Linhas.Add('VAL-R04: CFOP: 4 digitos entre 1000 e 7999');
      Linhas.Add('VAL-R05: Chave NFe: 44 digitos com DV calculado modulo 11');
      Linhas.Add('VAL-R06: NF-e sem tag <imposto>: documento incompleto');
      Linhas.Add('LIM-R01: NF-e > R$50k: verificar obrigatoriedade MDF-e');
      Linhas.Add('LIM-R02: Valor unitario > R$10k: verificar NCM e aliquota');
      Linhas.Add('LIM-R03: Documento > 1 ano: verificar prescricao (5 anos)');
    end;

    sgRegras.ColCount := 2;
    sgRegras.FixedRows := 1;
    sgRegras.RowCount := Linhas.Count + 1;
    sgRegras.Cells[0, 0] := 'Codigo';
    sgRegras.Cells[1, 0] := 'Regra Fiscal';
    sgRegras.ColWidths[0] := 85;
    sgRegras.ColWidths[1] := 305;
    for i := 0 to Linhas.Count - 1 do
    begin
      p := Pos(': ', Linhas[i]);
      if p > 0 then
      begin
        Codigo := Copy(Linhas[i], 1, p - 1);
        Descricao := Copy(Linhas[i], p + 2, MaxInt);
      end
      else
      begin
        Codigo := '';
        Descricao := Linhas[i];
      end;
      sgRegras.Cells[0, i + 1] := Trim(Codigo);
      sgRegras.Cells[1, i + 1] := Trim(Descricao);
    end;

    AtualizarStatus(Format('Regras fiscais: %d regras carregadas.', [Linhas.Count]));
    NotificarRegrasAlteradas;
  finally
    Linhas.Free;
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
  Linhas: TStringList;
  i: Integer;
begin
  try
    Caminho := ExtractFilePath(ParamStr(0)) + '..\..\Resources\' + ARQ_REGRAS_FISCAIS;
    ForceDirectories(ExtractFilePath(Caminho));
    Linhas := TStringList.Create;
    try
      for i := 1 to sgRegras.RowCount - 1 do
        if (sgRegras.Cells[0, i] <> '') or (sgRegras.Cells[1, i] <> '') then
          Linhas.Add(sgRegras.Cells[0, i] + ': ' + sgRegras.Cells[1, i]);
      Linhas.SaveToFile(Caminho);
    finally
      Linhas.Free;
    end;
    AtualizarStatus(Format('Regras salvas em disco (%d regras).', [sgRegras.RowCount - 1]));
  except
    on E: Exception do
      AtualizarStatus('ERRO ao salvar: ' + E.Message);
  end;
end;

procedure TfrmMain.btnAddRegraClick(Sender: TObject);
begin
  sgRegras.RowCount := sgRegras.RowCount + 1;
  sgRegras.Cells[0, sgRegras.RowCount - 1] := '';
  sgRegras.Cells[1, sgRegras.RowCount - 1] := '';
  sgRegras.Row := sgRegras.RowCount - 1;
  AtualizarStatus('Nova regra adicionada. Preencha codigo e descricao. Use Ctrl+S para salvar.');
end;

procedure TfrmMain.btnDelRegraClick(Sender: TObject);
var
  R, i: Integer;
begin
  R := sgRegras.Row;
  if (R < 1) or (R >= sgRegras.RowCount) then Exit;
  for i := R to sgRegras.RowCount - 2 do
  begin
    sgRegras.Cells[0, i] := sgRegras.Cells[0, i + 1];
    sgRegras.Cells[1, i] := sgRegras.Cells[1, i + 1];
  end;
  if sgRegras.RowCount > 2 then
    sgRegras.RowCount := sgRegras.RowCount - 1
  else
  begin
    sgRegras.Cells[0, 1] := '';
    sgRegras.Cells[1, 1] := '';
  end;
  AtualizarStatus('Regra removida. Use Ctrl+S para salvar as alteracoes.');
end;

end.
