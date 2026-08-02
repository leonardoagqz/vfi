unit VFI.UI.MainController;

interface

uses
  System.SysUtils, System.Generics.Collections,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TMainController = class(TInterfacedObject, IMainController)
  private
    FRepository: IFiscalDocumentRepository;
    FValidator: IFiscalValidator;
    FAIAnalyzer: IAIAnalyzer;
    FOnStatus: TStatusCallback;
    FDocumentos: TObjectList<TFiscalDocument>;
    FUltimoResultadoIA: TResultadoIA;
    FUltimaValidacao: TResultadoValidacao;
    FRegrasFiscais: string;
  public
    constructor Create(const ARepository: IFiscalDocumentRepository;
      const AValidator: IFiscalValidator; const AAIAnalyzer: IAIAnalyzer);
    destructor Destroy; override;

    procedure Inicializar;
    procedure CarregarDocumentos;
    procedure ImportarXml(const AArquivo: string);
    procedure ImportarMultiplosXmls(const AArquivos: TArray<string>);
    procedure ExcluirDocumento(const AId: Integer);
    procedure AnalisarComIA(const AId: Integer);
    function ObterDocumento(const AIndex: Integer): TFiscalDocument;
    function QuantidadeDocumentos: Integer;
    procedure SetOnStatus(const AProc: TStatusCallback);

    function ObterUltimoResultadoIA: TResultadoIA;
    function ObterUltimaValidacao: TResultadoValidacao;
    procedure SetRegrasFiscais(const ARegras: string);
    procedure ConfigurarAPI(const AApiKey, AEndpoint, AModel: string);
    function ValidarDocumentoAtual(const ADoc: TFiscalDocument): TResultadoValidacao;

    property Documentos: TObjectList<TFiscalDocument> read FDocumentos;
    property OnStatus: TStatusCallback read FOnStatus write FOnStatus;
  private
    procedure Status(const AMsg: string);
  end;

implementation

uses
  VFI.Services.XmlImporter, VFI.Services.AIAnalyzer;

constructor TMainController.Create(const ARepository: IFiscalDocumentRepository;
  const AValidator: IFiscalValidator; const AAIAnalyzer: IAIAnalyzer);
begin
  inherited Create;
  FRepository := ARepository;
  FValidator := AValidator;
  FAIAnalyzer := AAIAnalyzer;
  FDocumentos := TObjectList<TFiscalDocument>.Create(True);
  FillChar(FUltimoResultadoIA, SizeOf(FUltimoResultadoIA), 0);
end;

destructor TMainController.Destroy;
begin
  FDocumentos.Free;
  inherited;
end;

procedure TMainController.Status(const AMsg: string);
begin
  if Assigned(FOnStatus) then FOnStatus(AMsg);
end;

procedure TMainController.Inicializar;
begin
  CarregarDocumentos;
  Status('Sistema inicializado.');
end;

procedure TMainController.CarregarDocumentos;
begin
  FDocumentos.Clear;
  FDocumentos.AddRange(FRepository.BuscarTodos);
end;

procedure TMainController.ImportarXml(const AArquivo: string);
var
  Doc: TFiscalDocument;
  Importer: TXmlImporter;
  Calc: TTaxCalculation;
  ValResumo: string;
begin
  Importer := TXmlImporter.Create;
  try
    Doc := Importer.Importar(AArquivo);
  finally
    Importer.Free;
  end;

  if not Assigned(Doc) then
  begin
    Status('ERRO: XML invalido: ' + ExtractFileName(AArquivo));
    Exit;
  end;

  if FRepository.ExisteChave(Doc.Chave) then
  begin
    Status(Format('JA EXISTE: %s #%s - chave ja importada.', [TipoDocumentoToStr(Doc.Tipo), Doc.Numero]));
    Doc.Free;
    Exit;
  end;

  FRepository.Inserir(Doc);

  for Calc in Doc.Calculos do
  begin
    Calc.DocumentId := Doc.Id;
    if (Calc.ItemId >= 0) and (Calc.ItemId < Doc.Itens.Count) then
      Calc.ItemId := Doc.Itens[Calc.ItemId].Id
    else
      Calc.ItemId := -1;
    FRepository.InserirCalculo(Calc);
  end;

  FUltimaValidacao := FValidator.ValidarDocumento(Doc);
  if FUltimaValidacao.IsValid then
  begin
    FRepository.AtualizarStatus(Doc.Id, stValidado);
    ValResumo := 'VALIDO';
  end
  else
  begin
    FRepository.AtualizarStatus(Doc.Id, stRejeitado);
    ValResumo := Format('REJEITADO (%d erros)', [FUltimaValidacao.Erros.Count]);
  end;

  Status(Format('OK: %s #%s | %s | %d itens | %d impostos | R$ %s | %s',
    [TipoDocumentoToStr(Doc.Tipo), Doc.Numero, Copy(Doc.NomeEmitente, 1, 25),
     Doc.Itens.Count, Doc.Calculos.Count,
     FormatFloat('#,##0.00', Doc.ValorTotal), ValResumo]));

  Doc.Free;
  CarregarDocumentos;
end;

procedure TMainController.ImportarMultiplosXmls(const AArquivos: TArray<string>);
var
  i, Ok: Integer;
begin
  Ok := 0;
  for i := 0 to High(AArquivos) do
  begin
    try
      ImportarXml(AArquivos[i]);
      Inc(Ok);
    except
      on E: Exception do
        Status('FALHA: ' + ExtractFileName(AArquivos[i]) + ' - ' + E.Message);
    end;
  end;
  Status(Format('%d de %d importados com sucesso.', [Ok, Length(AArquivos)]));
  CarregarDocumentos;
end;

procedure TMainController.ExcluirDocumento(const AId: Integer);
begin
  FRepository.Excluir(AId);
  CarregarDocumentos;
end;

procedure TMainController.AnalisarComIA(const AId: Integer);
var
  Doc: TFiscalDocument;
begin
  Doc := FRepository.BuscarPorId(AId);
  if not Assigned(Doc) then Exit;
  try
    FUltimoResultadoIA := FAIAnalyzer.AnalisarDocumento(Doc);
    FRepository.InserirAnaliseIA(AId, FUltimoResultadoIA.Modelo, FUltimoResultadoIA.Prompt,
      FUltimoResultadoIA.Resposta, FUltimoResultadoIA.AnomaliasEncontradas, FUltimoResultadoIA.Confianca);
    Status(Format('IA: %d anomalia(s) (confianca %.0f%%) para doc #%d.',
      [FUltimoResultadoIA.AnomaliasEncontradas, FUltimoResultadoIA.Confianca * 100, AId]));
  finally
    Doc.Free;
  end;
end;

function TMainController.ObterDocumento(const AIndex: Integer): TFiscalDocument;
begin
  if (AIndex >= 0) and (AIndex < FDocumentos.Count) then
    Result := FDocumentos[AIndex]
  else
    Result := nil;
end;

function TMainController.QuantidadeDocumentos: Integer;
begin
  Result := FDocumentos.Count;
end;

procedure TMainController.SetOnStatus(const AProc: TStatusCallback);
begin
  FOnStatus := AProc;
end;

function TMainController.ObterUltimoResultadoIA: TResultadoIA;
begin
  Result := FUltimoResultadoIA;
end;

function TMainController.ObterUltimaValidacao: TResultadoValidacao;
begin
  Result := FUltimaValidacao;
end;

procedure TMainController.SetRegrasFiscais(const ARegras: string);
begin
  FRegrasFiscais := ARegras;
end;

procedure TMainController.ConfigurarAPI(const AApiKey, AEndpoint, AModel: string);
begin
  FAIAnalyzer := TAIAnalyzer.Create(AApiKey, AEndpoint, AModel);
end;

function TMainController.ValidarDocumentoAtual(const ADoc: TFiscalDocument): TResultadoValidacao;
begin
  Result := FValidator.ValidarDocumento(ADoc);
end;

end.
