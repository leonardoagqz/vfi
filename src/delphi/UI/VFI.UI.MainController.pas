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
    function ObterDocumento(const AIndex: Integer): TFiscalDocument;
    function QuantidadeDocumentos: Integer;
    procedure SetOnStatus(const AProc: TStatusCallback);

    property Documentos: TObjectList<TFiscalDocument> read FDocumentos;
    property OnStatus: TStatusCallback read FOnStatus write FOnStatus;
  private
    procedure Status(const AMsg: string);
  end;

implementation

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
  Status('Sistema inicializado. Repositorio, validador, calculadora fiscal e IA DeepSeek prontos.');
end;

procedure TMainController.CarregarDocumentos;
begin
  try
    FDocumentos.Clear;
    FDocumentos.AddRange(FRepository.BuscarTodos);
    Status(Format('%d documento(s) carregado(s).', [FDocumentos.Count]));
  except
    on E: Exception do
      Status('ERRO ao carregar: ' + E.Message);
  end;
end;

procedure TMainController.ValidarDocumento(const AId: Integer);
var
  Doc: TFiscalDocument;
  Resultado: TResultadoValidacao;
begin
  Doc := FRepository.BuscarPorId(AId);
  if not Assigned(Doc) then
  begin
    Status(Format('Documento #%d nao encontrado.', [AId]));
    Exit;
  end;
  try
    Resultado := FValidator.ValidarDocumento(Doc);
    if Resultado.IsValid then
    begin
      FRepository.AtualizarStatus(AId, stValidado);
      Status(Format('Documento #%d: VALIDO.', [AId]));
    end
    else
    begin
      FRepository.AtualizarStatus(AId, stRejeitado);
      Status(Format('Documento #%d: REJEITADO. %d erro(s). %s',
        [AId, Resultado.Erros.Count, Resultado.ErrosAsString]));
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
begin
  Doc := FRepository.BuscarPorId(AId);
  if not Assigned(Doc) then
  begin
    Status(Format('Documento #%d nao encontrado.', [AId]));
    Exit;
  end;
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
      Calc.Engine := Res.Engine;
      Calc.CST := Res.CST;
      Calc.CFOP := Res.CFOP;
      FRepository.InserirCalculo(Calc);
      Calc.Free;
    end;

    Status(Format('Impostos calculados para documento #%d (%d itens). Engine: %s.',
      [AId, Doc.Itens.Count, 'VB6/Internal']));
  finally
    Doc.Free;
  end;
end;

procedure TMainController.AnalisarComIA(const AId: Integer);
var
  Doc: TFiscalDocument;
  Res: TResultadoIA;
begin
  Doc := FRepository.BuscarPorId(AId);
  if not Assigned(Doc) then
  begin
    Status(Format('Documento #%d nao encontrado.', [AId]));
    Exit;
  end;
  try
    Res := FAIAnalyzer.AnalisarDocumento(Doc);

    FRepository.InserirAnaliseIA(AId, Res.Modelo, Res.Prompt, Res.Resposta, Res.AnomaliasEncontradas, Res.Confianca);

    Status(Format('Analise IA concluida para doc #%d. Modelo: %s. %d anomalia(s). Confianca: %.0f%%.',
      [AId, Res.Modelo, Res.AnomaliasEncontradas, Res.Confianca * 100]));
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

end.
