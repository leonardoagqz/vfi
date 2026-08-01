program VFI;

uses
  Vcl.Forms,
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
  VFI.Services.TaxCalculator in 'Services\VFI.Services.TaxCalculator.pas',
  VFI.Services.AIAnalyzer in 'Services\VFI.Services.AIAnalyzer.pas',
  VFI.Services.VB6Bridge in 'Services\VFI.Services.VB6Bridge.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  TAppModule.Inicializar;

  frmMain := TfrmMain.Create(Application);
  try
    frmMain.Controller := TMainController.Create(
      TAppModule.Repository,
      TAppModule.Validator,
      TAppModule.TaxCalculator,
      TAppModule.AIAnalyzer);
    frmMain.Controller.SetOnStatus(frmMain.AtualizarStatus);
    frmMain.Controller.Inicializar;

    Application.Run;
  finally
    frmMain.Free;
    TAppModule.Finalizar;
  end;
end.
