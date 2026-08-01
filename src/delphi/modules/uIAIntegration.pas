unit uIAIntegration;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient,
  System.Net.URLClient, System.Net.HttpClientComponent, System.JSON;

type
  TAIResult = record
    Model: string;
    Prompt: string;
    Response: string;
    AnomaliesFound: Integer;
    ConfidenceScore: Double;
  end;

  TIAIntegration = class(TComponent)
  private
    FHttpClient: TNetHTTPClient;
    FApiKey: string;
    FEndpoint: string;
    FModel: string;
    function BuildPrompt(const DocumentId: Integer): string;
    function CallOpenAI(const Prompt: string): string;
    function SimulateAnalysis(const DocumentId: Integer): TAIResult;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AnalisarDocumento(const DocumentId: Integer): TAIResult;
  end;

implementation

{ TIAIntegration }

constructor TIAIntegration.Create(AOwner: TComponent);
begin
  inherited;
  FHttpClient := TNetHTTPClient.Create(Self);
  FHttpClient.ContentType := 'application/json';

  { Configuracao - em producao carregaria de arquivo .env ou config }
  FApiKey := ''; { Preencher com chave da OpenAI ou Azure }
  FEndpoint := 'https://api.openai.com/v1/chat/completions';
  FModel := 'gpt-4o-mini';
end;

destructor TIAIntegration.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

function TIAIntegration.BuildPrompt(const DocumentId: Integer): string;
begin
  Result :=
    'Analise fiscal do documento #' + IntToStr(DocumentId) + sLineBreak +
    sLineBreak +
    'Voce e um auditor fiscal experiente especializado em NF-e, CT-e e MDF-e.' + sLineBreak +
    'Identifique e classifique:' + sLineBreak +
    '1. Inconsistencias nos valores calculados' + sLineBreak +
    '2. CFOP incompativel com NCM' + sLineBreak +
    '3. Valores suspeitos ou fora do padrao' + sLineBreak +
    '4. Problemas de enquadramento fiscal' + sLineBreak +
    sLineBreak +
    'Formato de resposta desejado: JSON com array de anomalias encontradas.';
end;

function TIAIntegration.CallOpenAI(const Prompt: string): string;
var
  RequestBody: TStringStream;
  Response: IHTTPResponse;
  JSONBody, JSONMessage, JSONMessages, JSONRequest: TJSONObject;
  JSONMessagesArray: TJSONArray;
begin
  if FApiKey.IsEmpty then
    Exit('[SIMULACAO] Chave de API nao configurada. Usando modo simulacao.');

  { Constroi o payload JSON para a API da OpenAI }
  JSONRequest := TJSONObject.Create;
  try
    JSONRequest.AddPair('model', FModel);
    JSONRequest.AddPair('temperature', TJSONNumber.Create(0.3));
    JSONRequest.AddPair('max_tokens', TJSONNumber.Create(1000));

    JSONMessagesArray := TJSONArray.Create;
    try
      JSONMessage := TJSONObject.Create;
      JSONMessage.AddPair('role', 'system');
      JSONMessage.AddPair('content', 'Voce e um auditor fiscal experiente.');
      JSONMessagesArray.Add(JSONMessage);

      JSONMessage := TJSONObject.Create;
      JSONMessage.AddPair('role', 'user');
      JSONMessage.AddPair('content', Prompt);
      JSONMessagesArray.Add(JSONMessage);

      JSONRequest.AddPair('messages', JSONMessagesArray);
    except
      JSONMessagesArray.Free;
      raise;
    end;

    RequestBody := TStringStream.Create(JSONRequest.ToJSON, TEncoding.UTF8);
    try
      FHttpClient.CustomHeaders['Authorization'] := 'Bearer ' + FApiKey;
      Response := FHttpClient.Post(FEndpoint, RequestBody);

      if Response.StatusCode = 200 then
        Result := Response.ContentAsString
      else
        Result := Format('[ERRO HTTP %d] %s', [Response.StatusCode, Response.ContentAsString]);
    finally
      RequestBody.Free;
    end;
  finally
    JSONRequest.Free;
  end;
end;

function TIAIntegration.SimulateAnalysis(const DocumentId: Integer): TAIResult;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Model := FModel + ' (simulacao)';
  Result.Prompt := BuildPrompt(DocumentId);
  Result.Response :=
    '{' + sLineBreak +
    '  "documento_id": ' + IntToStr(DocumentId) + ',' + sLineBreak +
    '  "status": "SIMULADO",' + sLineBreak +
    '  "anomalias": [' + sLineBreak +
    '    {"tipo": "ALERTA", "descricao": "Valor total acima de R$ 50.000,00. Verificar enquadramento fiscal."},' + sLineBreak +
    '    {"tipo": "INFO", "descricao": "Documento dentro do prazo de emissao regular."}' + sLineBreak +
    '  ],' + sLineBreak +
    '  "confianca": 0.85,' + sLineBreak +
    '  "recomendacao": "Documento aparenta conformidade. Revisar valores elevados."' + sLineBreak +
    '}';
  Result.AnomaliesFound := 2;
  Result.ConfidenceScore := 0.85;
end;

function TIAIntegration.AnalisarDocumento(const DocumentId: Integer): TAIResult;
var
  Prompt, ResponseContent: string;
begin
  Prompt := BuildPrompt(DocumentId);

  if FApiKey.IsEmpty then
  begin
    Result := SimulateAnalysis(DocumentId);
    Exit;
  end;

  ResponseContent := CallOpenAI(Prompt);

  FillChar(Result, SizeOf(Result), 0);
  Result.Model := FModel;
  Result.Prompt := Prompt;
  Result.Response := ResponseContent;

  { Contagem simples de palavras-chave na resposta }
  if ResponseContent.ToLower.Contains('anomalia') then Inc(Result.AnomaliesFound);
  if ResponseContent.ToLower.Contains('inconsistencia') then Inc(Result.AnomaliesFound);
  if ResponseContent.ToLower.Contains('irregularidade') then Inc(Result.AnomaliesFound);
  if ResponseContent.ToLower.Contains('erro') then Inc(Result.AnomaliesFound);
  if Result.AnomaliesFound = 0 then Result.AnomaliesFound := 1;

  Result.ConfidenceScore := 0.85;
end;

end.
