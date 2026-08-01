unit VFI.Data.Connection;

interface

uses
  System.SysUtils, Data.DB, Data.Win.ADODB;

type
  TConnectionFactory = class
  private
    class var FConnectionString: string;
  public
    class procedure Configure(const AServer, ADatabase, AUser, APassword: string);
    class function CriarConexao: TADOConnection;
  end;

implementation

class procedure TConnectionFactory.Configure(const AServer, ADatabase, AUser, APassword: string);
begin
  FConnectionString := Format(
    'Provider=MSDASQL.1;Persist Security Info=False;Data Source=VFI_DSN;User ID=%s;Password=%s;',
    [AUser, APassword]);
end;

class function TConnectionFactory.CriarConexao: TADOConnection;
begin
  Result := TADOConnection.Create(nil);
  try
    Result.ConnectionString := FConnectionString;
    Result.LoginPrompt := False;
    Result.Connected := True;
  except
    Result.Free;
    raise;
  end;
end;

end.
