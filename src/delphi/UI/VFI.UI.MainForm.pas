unit VFI.UI.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.Buttons,
  VFI.Domain.Interfaces, VFI.Domain.Entities, VFI.Domain.Enums;

type
  TfrmMain = class(TForm)
    pnlTop: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    lblDocCount: TLabel;
    Splitter1: TSplitter;
    pnlLeft: TPanel;
    StringGridDocs: TStringGrid;
    pnlRight: TPanel;
    gbDetalhes: TGroupBox;
    lblTipoVal: TLabel;
    lblNumeroVal: TLabel;
    lblEmitenteVal: TLabel;
    lblCNPJEVal: TLabel;
    lblDestVal: TLabel;
    lblCNPJDVal: TLabel;
    lblValorVal: TLabel;
    lblStatusVal: TLabel;
    lblTipo: TLabel;
    lblNumero: TLabel;
    lblEmitente: TLabel;
    lblCNPJE: TLabel;
    lblDest: TLabel;
    lblCNPJD: TLabel;
    lblValor: TLabel;
    lblStatus: TLabel;
    gbItens: TGroupBox;
    memItens: TMemo;
    pnlBottom: TPanel;
    pcLog: TPageControl;
    tsLog: TTabSheet;
    memLog: TMemo;
    tsIA: TTabSheet;
    memIA: TMemo;
    pnlActions: TPanel;
    btnImportar: TBitBtn;
    btnImportarVarios: TBitBtn;
    btnExcluir: TBitBtn;
    btnAtualizar: TBitBtn;
    btnValidar: TButton;
    btnCalcular: TButton;
    btnAnalisarIA: TButton;
    pnlStatus: TPanel;
    lblStatusMsg: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnValidarClick(Sender: TObject);
    procedure btnCalcularClick(Sender: TObject);
    procedure btnAnalisarIAClick(Sender: TObject);
    procedure btnImportarClick(Sender: TObject);
    procedure btnImportarVariosClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure StringGridDocsClick(Sender: TObject);
  private
    FController: IMainController;
    procedure AtualizarGrade;
    procedure MostrarDetalhes(const AIndex: Integer);
    procedure LimparDetalhes;
    function ObterIdSelecionado: Integer;
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

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Caption := 'VFI - Validador Fiscal Inteligente';

  StringGridDocs.ColCount := 6;
  StringGridDocs.RowCount := 2;
  StringGridDocs.FixedRows := 1;
  StringGridDocs.Cells[0, 0] := 'ID';
  StringGridDocs.Cells[1, 0] := 'Tipo';
  StringGridDocs.Cells[2, 0] := 'Numero';
  StringGridDocs.Cells[3, 0] := 'Emitente';
  StringGridDocs.Cells[4, 0] := 'Valor';
  StringGridDocs.Cells[5, 0] := 'Status';
  StringGridDocs.ColWidths[0] := 35;
  StringGridDocs.ColWidths[1] := 40;
  StringGridDocs.ColWidths[2] := 60;
  StringGridDocs.ColWidths[3] := 200;
  StringGridDocs.ColWidths[4] := 85;
  StringGridDocs.ColWidths[5] := 70;
  StringGridDocs.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect];

  pcLog.ActivePage := tsLog;

  LimparDetalhes;
  AtualizarStatus('Pronto. Clique em Importar XML para comecar.');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FController := nil;
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
  memItens.Clear;
end;

procedure TfrmMain.AtualizarStatus(const AMsg: string);
begin
  lblStatusMsg.Caption := AMsg;
  memLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AMsg);
end;

procedure TfrmMain.AtualizarGrade;
var
  i, Qtd: Integer;
  Doc: TFiscalDocument;
begin
  if not Assigned(FController) then Exit;
  Qtd := FController.QuantidadeDocumentos;
  lblDocCount.Caption := Format('%d documento(s)', [Qtd]);

  if Qtd = 0 then
  begin
    StringGridDocs.RowCount := 2;
    LimparDetalhes;
    Exit;
  end;

  StringGridDocs.RowCount := Qtd + 1;
  for i := 0 to Qtd - 1 do
  begin
    Doc := FController.ObterDocumento(i);
    if not Assigned(Doc) then Continue;
    StringGridDocs.Cells[0, i + 1] := IntToStr(Doc.Id);
    StringGridDocs.Cells[1, i + 1] := TipoDocumentoToStr(Doc.Tipo);
    StringGridDocs.Cells[2, i + 1] := Doc.Numero;
    StringGridDocs.Cells[3, i + 1] := Copy(Doc.NomeEmitente, 1, 30);
    StringGridDocs.Cells[4, i + 1] := FormatFloat('R$ #,##0.00', Doc.ValorTotal);
    StringGridDocs.Cells[5, i + 1] := StatusToStr(Doc.Status);
  end;
end;

procedure TfrmMain.MostrarDetalhes(const AIndex: Integer);
var
  Doc: TFiscalDocument;
  i: Integer;
  Item: TDocumentItem;
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
  lblCNPJEVal.Caption := Doc.CnpjEmitente;
  lblDestVal.Caption := Doc.NomeDestinatario;
  lblCNPJDVal.Caption := Doc.CnpjDestinatario;
  lblValorVal.Caption := FormatFloat('R$ #,##0.00', Doc.ValorTotal);
  lblStatusVal.Caption := StatusToStr(Doc.Status);

  memItens.Clear;
  for i := 0 to Doc.Itens.Count - 1 do
  begin
    Item := Doc.Itens[i];
    memItens.Lines.Add(Format('%s - %s', [Item.CodigoProduto, Item.NomeProduto]));
    memItens.Lines.Add(Format('  Qtd: %.0f  |  Unit: R$ %.2f  |  Total: R$ %.2f  |  NCM: %s  |  CFOP: %s',
      [Item.Quantidade, Item.ValorUnitario, Item.ValorTotal, Item.NCM, Item.CFOP]));
    memItens.Lines.Add('');
  end;
end;

function TfrmMain.ObterIdSelecionado: Integer;
var
  Row: Integer;
begin
  Row := StringGridDocs.Row;
  if (Row < 1) or (Row > StringGridDocs.RowCount - 1) then Exit(0);
  Result := StrToIntDef(StringGridDocs.Cells[0, Row], 0);
end;

procedure TfrmMain.StringGridDocsClick(Sender: TObject);
var
  Row: Integer;
begin
  Row := StringGridDocs.Row;
  if Row >= 1 then
    MostrarDetalhes(Row - 1);
end;

procedure TfrmMain.btnAtualizarClick(Sender: TObject);
begin
  if not Assigned(FController) then Exit;
  FController.CarregarDocumentos;
  AtualizarGrade;
  AtualizarStatus('Grade atualizada.');
end;

procedure TfrmMain.btnValidarClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := ObterIdSelecionado;
  if Id = 0 then
  begin
    AtualizarStatus('Selecione um documento na grid primeiro.');
    Exit;
  end;
  FController.ValidarDocumento(Id);
  btnAtualizarClick(Self);
end;

procedure TfrmMain.btnCalcularClick(Sender: TObject);
var
  Id: Integer;
begin
  Id := ObterIdSelecionado;
  if Id = 0 then
  begin
    AtualizarStatus('Selecione um documento na grid primeiro.');
    Exit;
  end;
  FController.CalcularImpostos(Id);
  AtualizarStatus(Format('ICMS calculado para documento #%d.', [Id]));
end;

procedure TfrmMain.btnAnalisarIAClick(Sender: TObject);
var
  Id: Integer;
  Doc: TFiscalDocument;
begin
  Id := ObterIdSelecionado;
  if Id = 0 then
  begin
    AtualizarStatus('Selecione um documento na grid primeiro.');
    Exit;
  end;

  Doc := FController.ObterDocumento(StringGridDocs.Row - 1);
  if Assigned(Doc) then
  begin
    memIA.Clear;
    memIA.Lines.Add('Enviando para DeepSeek...');
    memIA.Lines.Add(Format('Documento: %s #%s - %s',
      [TipoDocumentoToStr(Doc.Tipo), Doc.Numero, Doc.NomeEmitente]));
    memIA.Lines.Add(Format('Valor: R$ %.2f | Itens: %d', [Doc.ValorTotal, Doc.Itens.Count]));
    memIA.Lines.Add('');
  end;

  pcLog.ActivePage := tsIA;
  FController.AnalisarComIA(Id);
  AtualizarStatus(Format('Analise IA concluida para documento #%d.', [Id]));
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
    Dlg.DefaultExt := 'xml';
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
    Dlg.Title := 'Importar varios XMLs Fiscais';
    Dlg.Filter := 'XML Fiscal (*.xml)|*.xml';
    Dlg.DefaultExt := 'xml';
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
  if Id = 0 then
  begin
    AtualizarStatus('Selecione um documento na grid primeiro.');
    Exit;
  end;
  if MessageDlg(Format('Excluir documento #%d permanentemente?', [Id]),
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FController.ExcluirDocumento(Id);
    btnAtualizarClick(Self);
    AtualizarStatus(Format('Documento #%d excluido.', [Id]));
  end;
end;

end.
