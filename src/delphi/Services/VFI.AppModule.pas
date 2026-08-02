unit VFI.AppModule;

interface

uses
  System.SysUtils,
  VFI.Domain.Interfaces,
  VFI.Data.Config, VFI.Data.Connection, VFI.Data.Repository,
  VFI.Services.FiscalValidator, VFI.Services.TaxCalculator,
  VFI.Services.AIAnalyzer, VFI.Services.VB6Bridge;

type
  TAppModule = class
  private
    class var FConfig: TAppConfig;
    class var FRepository: IFiscalDocumentRepository;
    class var FValidator: IFiscalValidator;
    class var FTaxCalc: ITaxCalculator;
    class var FAIAnalyzer: IAIAnalyzer;
  public
    class procedure Inicializar;
    class procedure Finalizar;

    class property Config: TAppConfig read FConfig;
    class property Repository: IFiscalDocumentRepository read FRepository;
    class property Validator: IFiscalValidator read FValidator;
    class property TaxCalculator: ITaxCalculator read FTaxCalc;
    class property AIAnalyzer: IAIAnalyzer read FAIAnalyzer;
  end;

implementation

class procedure TAppModule.Inicializar;
begin
  FConfig := TAppConfig.Create;

  TConnectionFactory.Configure(
    FConfig.LeString('Database', 'User', 'vfi_app'),
    FConfig.LeString('Database', 'Password', 'Vfi@2024#Dev'));

  FRepository := TFiscalDocumentRepository.Create;
  FValidator := TFiscalValidator.Create;
  FTaxCalc := TVB6Bridge.Create;

  FAIAnalyzer := TAIAnalyzer.Create(
    FConfig.LeString('AI', 'ApiKey', ''),
    FConfig.LeString('AI', 'Endpoint', 'https://api.deepseek.com/v1/chat/completions'),
    FConfig.LeString('AI', 'Model', 'deepseek-chat'));
end;

class procedure TAppModule.Finalizar;
begin
  FConfig.Free;
end;

end.
