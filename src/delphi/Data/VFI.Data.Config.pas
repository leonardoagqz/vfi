unit VFI.Data.Config;

interface

uses
  System.SysUtils, System.IniFiles, System.IOUtils;

type
  TAppConfig = class
  private
    FIniFile: TMemIniFile;
  public
    constructor Create;
    destructor Destroy; override;
    function FindIniPath: string;

    function LeString(const ASecao, AChave, ADefault: string): string;
    function LeInteger(const ASecao, AChave: string; ADefault: Integer): Integer;
    function LeBool(const ASecao, AChave: string; ADefault: Boolean): Boolean;
  end;

implementation

constructor TAppConfig.Create;
var
  Path: string;
begin
  inherited;
  Path := FindIniPath;
  if (Path <> '') and TFile.Exists(Path) then
    FIniFile := TMemIniFile.Create(Path, TEncoding.UTF8)
  else
    FIniFile := TMemIniFile.Create('');
end;

destructor TAppConfig.Destroy;
begin
  FIniFile.Free;
  inherited;
end;

function TAppConfig.FindIniPath: string;
var
  ExeDir: string;
begin
  ExeDir := ExtractFilePath(ParamStr(0));
  ExeDir := ExcludeTrailingPathDelimiter(ExeDir);
  ExeDir := ExtractFilePath(ExeDir);
  Result := TPath.Combine(ExeDir, 'Resources\vfi.ini');
end;

function TAppConfig.LeString(const ASecao, AChave, ADefault: string): string;
begin
  Result := FIniFile.ReadString(ASecao, AChave, ADefault);
  if Result = '' then
    Result := ADefault;
end;

function TAppConfig.LeInteger(const ASecao, AChave: string; ADefault: Integer): Integer;
begin
  Result := FIniFile.ReadInteger(ASecao, AChave, ADefault);
end;

function TAppConfig.LeBool(const ASecao, AChave: string; ADefault: Boolean): Boolean;
begin
  Result := FIniFile.ReadBool(ASecao, AChave, ADefault);
end;

end.
