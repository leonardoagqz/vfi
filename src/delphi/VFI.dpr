program VFI;

uses
  Vcl.Forms, Vcl.Dialogs, System.SysUtils,
  VFI.UI.MainForm in 'UI\VFI.UI.MainForm.pas' {frmMain},
  VFI.UI.MainController in 'UI\VFI.UI.MainController.pas',
  VFI.AppModule in 'Services\VFI.AppModule.pas',
  VFI.Domain.Entities in 'Domain\VFI.Domain.Entities.pas',
  VFI.Domain.Enums in 'Domain\VFI.Domain.Enums.pas',
  VFI.Domain.Interfaces in 'Domain\VFI.Domain.Interfaces.pas',
  VFI.Data.Config in 'Data\VFI.Data.Config.pas',
  VFI.Data.Connection in 'Data\VFI.Data.Connection.pas',
  VFI.Data.Repository in 'Data\VFI.Data.Repository.pas',
  VFI.Services.FiscalValidator in 'Services\VFI.Services.FiscalValidator.pas',
  VFI.Services.AIAnalyzer in 'Services\VFI.Services.AIAnalyzer.pas',
  VFI.Services.XmlImporter in 'Services\VFI.Services.XmlImporter.pas';

{$R *.res}

begin
  try
    Application.Initialize;
    Application.MainFormOnTaskbar := True;

    TAppModule.Inicializar;

    Application.CreateForm(TfrmMain, frmMain);
    frmMain.Controller := TMainController.Create(
      TAppModule.Repository,
      TAppModule.Validator,
      TAppModule.AIAnalyzer);
    frmMain.Controller.SetOnStatus(frmMain.AtualizarStatus);
    frmMain.Controller.Inicializar;

    Application.Run;
  except
    on E: Exception do
      ShowMessage('Erro ao iniciar: ' + E.Message);
  end;
end.
