program VFI;

uses
  Vcl.Forms,
  frmMain in 'forms\frmMain.pas' {FormMain},
  dmVFI in 'modules\dmVFI.pas' {DataModuleVFI: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDataModuleVFI, DataModuleVFI);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
