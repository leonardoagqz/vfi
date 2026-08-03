unit VFI.AppModule;

interface

uses
  System.SysUtils,
  VFI.Domain.Interfaces,
  VFI.Data.Config, VFI.Data.Connection, VFI.Data.Repository,
  VFI.Services.FiscalValidator, VFI.Services.AIAnalyzer;

type
  TAppModule = class
  private
    class var FConfig: TAppConfig;
    class var FRepository: IFiscalDocumentRepository;
    class var FValidator: IFiscalValidator;
    class var FAIAnalyzer: IAIAnalyzer;
  public
    class procedure Inicializar;
    class procedure Finalizar;
    class procedure ReconfigurarIA(const AApiKey, AEndpoint, AModel: string);

    class property Config: TAppConfig read FConfig;
    class property Repository: IFiscalDocumentRepository read FRepository;
    class property Validator: IFiscalValidator read FValidator;
    class property AIAnalyzer: IAIAnalyzer read FAIAnalyzer;
  end;

implementation

class procedure TAppModule.Inicializar;
begin
  FConfig := TAppConfig.Create;

  TConnectionFactory.Configure(
    FConfig.LeString('Database', 'User', 'vfi_app'),
    FConfig.LeString('Database', 'Password', FConfig.LeString('Database', 'Password', '')));

  FRepository := TFiscalDocumentRepository.Create;
  FValidator := TFiscalValidator.Create;

  FAIAnalyzer := TAIAnalyzer.Create(
    FConfig.LeString('AI', 'ApiKey', ''),
    FConfig.LeString('AI', 'Endpoint', 'https://api.deepseek.com/v1/chat/completions'),
    FConfig.LeString('AI', 'Model', 'deepseek-chat'));
end;

class procedure TAppModule.Finalizar;
begin
  FConfig.Free;
end;

class procedure TAppModule.ReconfigurarIA(const AApiKey, AEndpoint, AModel: string);
begin
  FAIAnalyzer := TAIAnalyzer.Create(AApiKey, AEndpoint, AModel);
end;

end.
