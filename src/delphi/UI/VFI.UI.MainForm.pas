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
    tsRegras: TTabSheet; lvRegras: TListView; pnlRegrasBotoes: TPanel;
    btnAddRegra: TButton; btnEditRegra: TButton; btnDelRegra: TButton;
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
    procedure btnEditRegraClick(Sender: TObject);
    procedure btnDelRegraClick(Sender: TObject);
    procedure lvDocsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    FController: IMainController;
    procedure MostrarDetalhes(const AIndex: Integer); procedure LimparDetalhes;
    procedure LimparLogs;
    procedure AtualizarValidacaoSelecionada(const ADoc: TFiscalDocument);
    procedure CarregarRegrasPadrao;
    function ObterIdSelecionado: Integer; function ObterIndexSelecionado: Integer;
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
  
  lvRegras.ViewStyle:=vsReport; lvRegras.RowSelect:=True; lvRegras.GridLines:=True;
  lvRegras.Columns[2].AutoSize := True;
  pcDetalhes.ActivePage:=tsItens; pcBottom.ActivePage:=tsLog;
  LimparDetalhes;
  AtualizarStatus('Pronto. Use Importar para carregar XMLs fiscais.');
end;

procedure TfrmMain.FormDestroy(Sender: TObject); begin FController:=nil; end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift=[ssCtrl] then case Key of
    Ord('I'): btnImportarClick(Self); Ord('A'): btnAnalisarIAClick(Self); end
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
  CarregarRegrasPadrao;
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
  pcDetalhes.ActivePage:=tsAnaliseIA; Application.ProcessMessages;

  FController.AnalisarComIA(Id); R:=FController.ObterUltimoResultadoIA;

  memResultadoIA.Lines.Add(Format('Modelo: %s | Padroes suspeitos: %d | Confianca: %.0f%%',
    [R.Modelo,R.AnomaliasEncontradas,R.Confianca*100]));
  memResultadoIA.Lines.Add('');
  if R.Resposta<>'' then memResultadoIA.Lines.Add(R.Resposta)
  else memResultadoIA.Lines.Add('[Chave API nao configurada - usando analise local]');
end;

procedure TfrmMain.CarregarRegrasPadrao;
var
  Regras: TArrayOfAiRule;
  i: Integer;
  LI: TListItem;
  RegrasTexto: string;
begin
  if not Assigned(FController) then Exit;
  Regras := FController.ListarRegrasIA;
  
  lvRegras.Items.BeginUpdate;
  try
    lvRegras.Items.Clear;
    RegrasTexto := '';
    if Length(Regras) > 0 then
    begin
      for i := 0 to High(Regras) do
      begin
        LI := lvRegras.Items.Add;
        LI.Caption := IntToStr(Regras[i].Id);
        LI.SubItems.Add(Regras[i].Description);
        LI.SubItems.Add(Regras[i].Severity);
        LI.SubItems.Add(Regras[i].UpdatedAt);
        RegrasTexto := RegrasTexto + Format('%d. [%s] %s' + sLineBreak,
          [i + 1, Regras[i].Severity, Regras[i].Description]);
      end;
      FController.SetRegrasFiscais(RegrasTexto);
      AtualizarStatus(Format('Regras carregadas e enviadas para IA: %d ativas.', [Length(Regras)]));
    end
    else
    begin
      LI := lvRegras.Items.Add;
      LI.Caption := '-';
      LI.SubItems.Add('API offline. Inicie a API em localhost:5000');
      LI.SubItems.Add('INFO');
      AtualizarStatus('API nao encontrada. Regras nao enviadas para IA.');
    end;
  finally
    lvRegras.Items.EndUpdate;
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

procedure TfrmMain.btnAddRegraClick(Sender: TObject);
var
  Descricao: string;
begin
  if not Assigned(FController) then Exit;
  Descricao := InputBox('Nova Regra', 'Descricao da regra fiscal:', '');
  if Descricao = '' then Exit;
  
  FController.AdicionarRegraIA(Descricao);
  CarregarRegrasPadrao;
end;

procedure TfrmMain.btnDelRegraClick(Sender: TObject);
var
  Id: Integer;
begin
  if not Assigned(FController) then Exit;
  if not Assigned(lvRegras.Selected) then
  begin
    AtualizarStatus('Selecione uma regra para excluir.');
    Exit;
  end;
  
  Id := StrToIntDef(lvRegras.Selected.Caption, 0);
  if MessageDlg(Format('Excluir a regra #%d?', [Id]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FController.ExcluirRegraIA(Id);
    CarregarRegrasPadrao;
  end;
end;

procedure TfrmMain.btnEditRegraClick(Sender: TObject);
var
  Id: Integer;
  NovaDesc: string;
begin
  if not Assigned(FController) then Exit;
  if not Assigned(lvRegras.Selected) then
  begin
    AtualizarStatus('Selecione uma regra para editar.');
    Exit;
  end;
  Id := StrToIntDef(lvRegras.Selected.Caption, 0);
  if Id = 0 then Exit;
  
  NovaDesc := InputBox('Editar Regra #' + IntToStr(Id), 'Descricao:', lvRegras.Selected.SubItems[0]);
  if NovaDesc = '' then Exit;
  
  FController.AtualizarRegraIA(Id, NovaDesc);
  CarregarRegrasPadrao;
  AtualizarStatus(Format('Regra #%d atualizada.', [Id]));
end;

end.
