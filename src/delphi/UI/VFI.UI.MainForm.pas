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
    pcMain: TPageControl;
    tsDocumentos: TTabSheet;
    tsValidacao: TTabSheet;
    tsIA: TTabSheet;
    StringGridDocs: TStringGrid;
    pnlActions: TPanel;
    btnImportar: TButton;
    btnValidar: TButton;
    btnCalcular: TButton;
    btnAnalisarIA: TButton;
    btnRefresh: TBitBtn;
    pnlStatus: TPanel;
    lblStatus: TLabel;
    memLog: TMemo;
    lblLog: TLabel;
    memResultadoIA: TMemo;
    lblResultadoIA: TLabel;
    btnAnalisar: TButton;
    pnlHeader: TPanel;
    Shape1: TShape;
    cbFiltroTipo: TComboBox;
    lblFiltro: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnValidarClick(Sender: TObject);
    procedure btnCalcularClick(Sender: TObject);
    procedure btnAnalisarIAClick(Sender: TObject);
    procedure btnImportarClick(Sender: TObject);
    procedure StringGridDocsDblClick(Sender: TObject);
  private
    FController: IMainController;
    procedure AtualizarGrade;
  public
    procedure AtualizarStatus(const AMsg: string);
    property Controller: IMainController read FController write FController;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  pcMain.ActivePageIndex := 0;
  cbFiltroTipo.Items.Add('TODOS');
  cbFiltroTipo.Items.Add('NFe');
  cbFiltroTipo.Items.Add('CTe');
  cbFiltroTipo.Items.Add('MDFe');
  cbFiltroTipo.ItemIndex := 0;

  StringGridDocs.ColCount := 7;
  StringGridDocs.RowCount := 2;
  StringGridDocs.Cells[0, 0] := 'ID';
  StringGridDocs.Cells[1, 0] := 'Tipo';
  StringGridDocs.Cells[2, 0] := 'Numero';
  StringGridDocs.Cells[3, 0] := 'Emitente';
  StringGridDocs.Cells[4, 0] := 'Valor';
  StringGridDocs.Cells[5, 0] := 'Status';
  StringGridDocs.Cells[6, 0] := 'Itens';
  StringGridDocs.ColWidths[0] := 40;
  StringGridDocs.ColWidths[1] := 50;
  StringGridDocs.ColWidths[2] := 70;
  StringGridDocs.ColWidths[3] := 180;
  StringGridDocs.ColWidths[4] := 80;
  StringGridDocs.ColWidths[5] := 70;
  StringGridDocs.ColWidths[6] := 40;

  AtualizarStatus('Pronto. Aguardando inicializacao...');
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FController := nil;
end;

procedure TfrmMain.AtualizarStatus(const AMsg: string);
begin
  lblStatus.Caption := AMsg;
  memLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + AMsg);
end;

procedure TfrmMain.AtualizarGrade;
var
  i, Qtd: Integer;
  Doc: TFiscalDocument;
begin
  if not Assigned(FController) then
    Exit;

  Qtd := FController.QuantidadeDocumentos;
  if Qtd = 0 then
  begin
    StringGridDocs.RowCount := 2;
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
    StringGridDocs.Cells[3, i + 1] := Copy(Doc.NomeEmitente, 1, 25);
    StringGridDocs.Cells[4, i + 1] := FormatCurr('R$ #,##0.00', Doc.ValorTotal);
    StringGridDocs.Cells[5, i + 1] := StatusToStr(Doc.Status);
    StringGridDocs.Cells[6, i + 1] := IntToStr(Doc.Itens.Count);
  end;
end;

procedure TfrmMain.btnRefreshClick(Sender: TObject);
begin
  if not Assigned(FController) then
  begin
    AtualizarStatus('ERRO: Controller nao inicializado.');
    Exit;
  end;
  FController.CarregarDocumentos;
  AtualizarGrade;
end;

procedure TfrmMain.btnValidarClick(Sender: TObject);
var
  Row: Integer;
  DocId: Integer;
begin
  if not Assigned(FController) then Exit;
  Row := StringGridDocs.Row;
  if Row < 1 then Exit;
  DocId := StrToIntDef(StringGridDocs.Cells[0, Row], 0);
  if DocId = 0 then Exit;
  FController.ValidarDocumento(DocId);
  btnRefreshClick(Self);
end;

procedure TfrmMain.btnCalcularClick(Sender: TObject);
var
  Row: Integer;
  DocId: Integer;
begin
  if not Assigned(FController) then Exit;
  Row := StringGridDocs.Row;
  if Row < 1 then Exit;
  DocId := StrToIntDef(StringGridDocs.Cells[0, Row], 0);
  if DocId = 0 then Exit;
  FController.CalcularImpostos(DocId);
end;

procedure TfrmMain.btnAnalisarIAClick(Sender: TObject);
var
  Row: Integer;
  DocId: Integer;
begin
  if not Assigned(FController) then Exit;
  Row := StringGridDocs.Row;
  if Row < 1 then Exit;
  DocId := StrToIntDef(StringGridDocs.Cells[0, Row], 0);
  if DocId = 0 then Exit;
  pcMain.ActivePage := tsIA;
  FController.AnalisarComIA(DocId);
  memResultadoIA.Lines.Add(Format('Analise IA (DeepSeek) concluida para documento #%d.', [DocId]));
end;

procedure TfrmMain.btnImportarClick(Sender: TObject);
begin
  AtualizarStatus('Importacao XML disponivel via API REST: http://localhost:5000/swagger');
end;

procedure TfrmMain.StringGridDocsDblClick(Sender: TObject);
var
  Row: Integer;
begin
  Row := StringGridDocs.Row;
  if Row < 1 then Exit;
  AtualizarStatus(Format('Documento #%s selecionado.', [StringGridDocs.Cells[0, Row]]));
end;

end.
