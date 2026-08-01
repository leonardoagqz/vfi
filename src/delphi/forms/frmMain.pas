unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Data.DB,
  Vcl.Buttons, dmVFI;

type
  TFormMain = class(TForm)
    pnlTop: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    pcMain: TPageControl;
    tsDocumentos: TTabSheet;
    tsValidacao: TTabSheet;
    tsIA: TTabSheet;
    dbgDocumentos: TDBGrid;
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
    procedure btnRefreshClick(Sender: TObject);
    procedure btnValidarClick(Sender: TObject);
    procedure btnCalcularClick(Sender: TObject);
    procedure btnAnalisarIAClick(Sender: TObject);
    procedure btnImportarClick(Sender: TObject);
    procedure dbgDocumentosDblClick(Sender: TObject);
  private
    procedure AtualizarStatus(const Msg: string);
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  pcMain.ActivePageIndex := 0;
  AtualizarStatus('Pronto. Conectado ao banco VFI_DB.');

  cbFiltroTipo.Items.Add('TODOS');
  cbFiltroTipo.Items.Add('NFe');
  cbFiltroTipo.Items.Add('CTe');
  cbFiltroTipo.Items.Add('MDFe');
  cbFiltroTipo.ItemIndex := 0;

  btnRefreshClick(Self);
end;

procedure TFormMain.AtualizarStatus(const Msg: string);
begin
  lblStatus.Caption := Msg;
  memLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + Msg);
end;

procedure TFormMain.btnRefreshClick(Sender: TObject);
begin
  DataModuleVFI.CarregarDocumentos;
  AtualizarStatus(Format('Grade atualizada. %d documentos carregados.',
    [DataModuleVFI.qryDocumentos.RecordCount]));
end;

procedure TFormMain.btnValidarClick(Sender: TObject);
begin
  if DataModuleVFI.qryDocumentos.IsEmpty then
  begin
    ShowMessage('Nenhum documento selecionado.');
    Exit;
  end;

  DataModuleVFI.ValidarDocumento(DataModuleVFI.qryDocumentos.FieldByName('Id').AsInteger);
  AtualizarStatus('Validacao concluida.');
  btnRefreshClick(Self);
end;

procedure TFormMain.btnCalcularClick(Sender: TObject);
begin
  if DataModuleVFI.qryDocumentos.IsEmpty then
  begin
    ShowMessage('Nenhum documento selecionado.');
    Exit;
  end;

  DataModuleVFI.CalcularImpostos(DataModuleVFI.qryDocumentos.FieldByName('Id').AsInteger);
  AtualizarStatus('Calculo de impostos concluido via DLL VB6 (COM).');
end;

procedure TFormMain.btnAnalisarIAClick(Sender: TObject);
begin
  if DataModuleVFI.qryDocumentos.IsEmpty then
  begin
    ShowMessage('Nenhum documento selecionado.');
    Exit;
  end;

  pcMain.ActivePage := tsIA;
  DataModuleVFI.AnalisarComIA(DataModuleVFI.qryDocumentos.FieldByName('Id').AsInteger);
  memResultadoIA.Lines.Add('Analise IA concluida para o documento #' +
    DataModuleVFI.qryDocumentos.FieldByName('Id').AsString);
  AtualizarStatus('Analise IA concluida.');
end;

procedure TFormMain.btnImportarClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(Self);
  try
    OpenDialog.Title := 'Importar XML Fiscal';
    OpenDialog.Filter := 'Arquivos XML (*.xml)|*.xml|Todos os arquivos (*.*)|*.*';
    OpenDialog.DefaultExt := 'xml';

    if OpenDialog.Execute then
    begin
      AtualizarStatus('XML importado: ' + OpenDialog.FileName);
      ShowMessage('Funcionalidade de importacao XML sera processada via API REST.');
    end;
  finally
    OpenDialog.Free;
  end;
end;

procedure TFormMain.dbgDocumentosDblClick(Sender: TObject);
begin
  pcMain.ActivePage := tsDocumentos;
  AtualizarStatus(Format('Documento #%d selecionado.',
    [DataModuleVFI.qryDocumentos.FieldByName('Id').AsInteger]));
end;

end.
