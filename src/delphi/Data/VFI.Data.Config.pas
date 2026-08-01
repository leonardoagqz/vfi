unit VFI.Data.Config;

interface

uses
  System.SysUtils, System.IniFiles;

type
  TAppConfig = class
  private
    FIniFile: TMemIniFile;
    function GetIniPath: string;
  public
    constructor Create;
    destructor Destroy; override;

    function LeString(const ASecao, AChave, ADefault: string): string;
    function LeInteger(const ASecao, AChave: string; ADefault: Integer): Integer;
    function LeBool(const ASecao, AChave: string; ADefault: Boolean): Boolean;
  end;

implementation

constructor TAppConfig.Create;
begin
  inherited;
  FIniFile := TMemIniFile.Create(GetIniPath, TEncoding.UTF8);
end;

destructor TAppConfig.Destroy;
begin
  FIniFile.UpdateFile;
  FIniFile.Free;
  inherited;
end;

function TAppConfig.GetIniPath: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'vfi.ini';
  if not FileExists(Result) then
    Result := ExtractFilePath(ParamStr(0)) + '..\..\Resources\vfi.ini';
end;

function TAppConfig.LeString(const ASecao, AChave, ADefault: string): string;
begin
  Result := FIniFile.ReadString(ASecao, AChave, ADefault);
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
