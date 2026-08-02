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
    FTaxCalc: ITaxCalculator;
    FAIAnalyzer: IAIAnalyzer;
    FOnStatus: TStatusCallback;
    FDocumentos: TObjectList<TFiscalDocument>;
    FUltimoResultadoIA: TResultadoIA;
  public
    constructor Create(const ARepository: IFiscalDocumentRepository;
      const AValidator: IFiscalValidator; const ATaxCalc: ITaxCalculator;
      const AAIAnalyzer: IAIAnalyzer);
    destructor Destroy; override;

    procedure Inicializar;
    procedure CarregarDocumentos;
    procedure ValidarDocumento(const AId: Integer);
    procedure CalcularImpostos(const AId: Integer);
    procedure AnalisarComIA(const AId: Integer);
    procedure ImportarXml(const AArquivo: string);
    procedure ImportarMultiplosXmls(const AArquivos: TArray<string>);
    procedure ExcluirDocumento(const AId: Integer);
    function ObterDocumento(const AIndex: Integer): TFiscalDocument;
    function QuantidadeDocumentos: Integer;
    function ObterUltimoResultadoIA: TResultadoIA;
    procedure SetOnStatus(const AProc: TStatusCallback);

    property Documentos: TObjectList<TFiscalDocument> read FDocumentos;
    property OnStatus: TStatusCallback read FOnStatus write FOnStatus;
  private
    procedure Status(const AMsg: string);
  end;

implementation

uses
  VFI.Services.XmlImporter;

constructor TMainController.Create(const ARepository: IFiscalDocumentRepository;
  const AValidator: IFiscalValidator; const ATaxCalc: ITaxCalculator;
  const AAIAnalyzer: IAIAnalyzer);
begin
  inherited Create;
  FRepository := ARepository;
  FValidator := AValidator;
  FTaxCalc := ATaxCalc;
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
  if Assigned(FOnStatus) then
    FOnStatus(AMsg);
end;

procedure TMainController.Inicializar;
begin
  CarregarDocumentos;
  Status('Sistema inicializado.');
end;

procedure TMainController.CarregarDocumentos;
begin
  try
    FDocumentos.Clear;
    FDocumentos.AddRange(FRepository.BuscarTodos);
  except
    on E: Exception do
      Status('ERRO: ' + E.Message);
  end;
end;

procedure TMainController.ValidarDocumento(const AId: Integer);
var
  Doc: TFiscalDocument;
  Resultado: TResultadoValidacao;
begin
  Doc := FRepository.BuscarPorId(AId);
  if not Assigned(Doc) then Exit;
  try
    Resultado := FValidator.ValidarDocumento(Doc);
    if Resultado.IsValid then
    begin
      FRepository.AtualizarStatus(AId, stValidado);
      Status(Format('Doc #%d VALIDO - CNPJ, NCM, CFOP e chave OK.', [AId]));
    end
    else
    begin
      FRepository.AtualizarStatus(AId, stRejeitado);
      Status(Format('Doc #%d REJEITADO - %d erro(s):', [AId, Resultado.Erros.Count]));
      Status(Resultado.ErrosAsString);
    end;
  finally
    Doc.Free;
  end;
end;

procedure TMainController.CalcularImpostos(const AId: Integer);
var
  Doc: TFiscalDocument;
  Item: TDocumentItem;
  Res: TResultadoCalculo;
  Calc: TTaxCalculation;
  TotalICMS: Currency;
begin
  Doc := FRepository.BuscarPorId(AId);
  if not Assigned(Doc) then Exit;
  TotalICMS := 0;
  try
    for Item in Doc.Itens do
    begin
      Res := FTaxCalc.CalcularICMS(Item.ValorTotal, 18, 0, 0, 0, 0, 0, omNacional, rtLucroReal);
      Calc := TTaxCalculation.Create;
      Calc.DocumentId := AId;
      Calc.ItemId := Item.Id;
      Calc.TipoImposto := tiICMS;
      Calc.BaseCalculo := Res.BaseCalculo;
      Calc.Aliquota := Res.Aliquota;
      Calc.ValorImposto := Res.ValorImposto;
      Calc.Engine := ecInternal;
      Calc.CST := Res.CST;
      Calc.CFOP := Res.CFOP;
      FRepository.InserirCalculo(Calc);
      TotalICMS := TotalICMS + Res.ValorImposto;
      Status(Format('  %s: base R$ %.2f x %d%% = ICMS R$ %.2f',
        [Item.NomeProduto, Res.BaseCalculo, Round(Res.Aliquota), Res.ValorImposto]));
      Calc.Free;
    end;
    Status(Format('Doc #%d: ICMS total = R$ %.2f (%d itens).', [AId, TotalICMS, Doc.Itens.Count]));
  finally
    Doc.Free;
  end;
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
    Status(Format('IA: %d anomalia(s) encontrada(s). Confianca: %.0f%%.',
      [FUltimoResultadoIA.AnomaliasEncontradas, FUltimoResultadoIA.Confianca * 100]));
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

procedure TMainController.ImportarXml(const AArquivo: string);
var
  Doc: TFiscalDocument;
  Importer: TXmlImporter;
begin
  Importer := TXmlImporter.Create;
  try
    Doc := Importer.Importar(AArquivo);
  finally
    Importer.Free;
  end;

  if not Assigned(Doc) then
  begin
    Status('ERRO: XML invalido.');
    Exit;
  end;

  try
    FRepository.Inserir(Doc);
    Status(Format('IMPORTADO: %s #%s | %s | %d itens | R$ %.2f',
      [TipoDocumentoToStr(Doc.Tipo), Doc.Numero, Copy(Doc.NomeEmitente, 1, 25),
       Doc.Itens.Count, Doc.ValorTotal]));
  finally
    Doc.Free;
  end;
end;

procedure TMainController.ImportarMultiplosXmls(const AArquivos: TArray<string>);
var
  i, Sucessos: Integer;
begin
  Sucessos := 0;
  for i := 0 to High(AArquivos) do
  begin
    try
      ImportarXml(AArquivos[i]);
      Inc(Sucessos);
    except
      on E: Exception do
        Status('FALHA: ' + ExtractFileName(AArquivos[i]) + ' - ' + E.Message);
    end;
  end;
  Status(Format('%d de %d XML(s) importado(s) com sucesso.', [Sucessos, Length(AArquivos)]));
end;

procedure TMainController.ExcluirDocumento(const AId: Integer);
begin
  FRepository.Excluir(AId);
end;

function TMainController.ObterUltimoResultadoIA: TResultadoIA;
begin
  Result := FUltimoResultadoIA;
end;

end.
