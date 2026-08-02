unit VFI.Services.AIAnalyzer;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient,
  System.Net.URLClient, System.JSON,
  VFI.Domain.Entities, VFI.Domain.Enums, VFI.Domain.Interfaces;

type
  TAIAnalyzer = class(TInterfacedObject, IAIAnalyzer)
  private
    FHttpClient: THttpClient;
    FApiKey: string;
    FEndpoint: string;
    FModel: string;
    function BuildPrompt(const ADocument: TFiscalDocument): string;
    function CallDeepSeekAPI(const APrompt: string): string;
    function ParseResponse(const AJson: string): TResultadoIA;
    function SimulateAnalysis(const ADocument: TFiscalDocument): TResultadoIA;
  public
    constructor Create(const AApiKey, AEndpoint, AModel: string);
    destructor Destroy; override;
    function AnalisarDocumento(const ADocument: TFiscalDocument): TResultadoIA;
  end;

implementation

constructor TAIAnalyzer.Create(const AApiKey, AEndpoint, AModel: string);
begin
  inherited Create;
  FApiKey := AApiKey;
  FEndpoint := AEndpoint;
  FModel := AModel;
  FHttpClient := THttpClient.Create;
  FHttpClient.ContentType := 'application/json';
  FHttpClient.ConnectionTimeout := 30000;
  FHttpClient.ResponseTimeout := 30000;
end;

destructor TAIAnalyzer.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

function TAIAnalyzer.BuildPrompt(const ADocument: TFiscalDocument): string;
var
  SB: TStringBuilder;
  Item: TDocumentItem;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendLine('Analise fiscal do seguinte documento:');
    SB.AppendLine(Format('  Tipo: %s', [TipoDocumentoToStr(ADocument.Tipo)]));
    SB.AppendLine(Format('  Chave: %s', [ADocument.Chave]));
    SB.AppendLine(Format('  Numero: %s', [ADocument.Numero]));
    SB.AppendLine(Format('  Emitente: %s (CNPJ: %s)', [ADocument.NomeEmitente, ADocument.CnpjEmitente]));
    SB.AppendLine(Format('  Destinatario: %s (CNPJ: %s)', [ADocument.NomeDestinatario, ADocument.CnpjDestinatario]));
    SB.AppendLine(Format('  Valor Total: R$ %.2f', [ADocument.ValorTotal]));
    SB.AppendLine(Format('  Data: %s', [DateToStr(ADocument.DataEmissao)]));
    SB.AppendLine;

    if ADocument.Itens.Count > 0 then
    begin
      SB.AppendLine('Itens:');
      for Item in ADocument.Itens do
        SB.AppendLine(Format('  - %s: %s | Qtd: %.2f | Valor: R$ %.2f | NCM: %s | CFOP: %s',
          [Item.CodigoProduto, Item.NomeProduto, Item.Quantidade, Item.ValorTotal, Item.NCM, Item.CFOP]));
    end;

    SB.AppendLine;
    SB.AppendLine('Identifique anomalias fiscais: CFOP incompativel com NCM, valores suspeitos, prazos irregulares.');
    SB.AppendLine('Responda em JSON: {"anomalias": [{"tipo":"CRITICO|ALERTA|INFO","descricao":"..."}], "confianca":0.0-1.0, "recomendacao":"..."}');

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

function TAIAnalyzer.CallDeepSeekAPI(const APrompt: string): string;
var
  RequestBody: TStringStream;
  Response: IHTTPResponse;
  JSONRequest, JSONMessage: TJSONObject;
  JSONMessages: TJSONArray;
begin
  if FApiKey.IsEmpty then
    Exit('');

  JSONRequest := TJSONObject.Create;
  try
    JSONRequest.AddPair('model', FModel);
    JSONRequest.AddPair('temperature', TJSONNumber.Create(0.3));
    JSONRequest.AddPair('max_tokens', TJSONNumber.Create(1000));

    JSONMessages := TJSONArray.Create;
    JSONMessage := TJSONObject.Create;
    JSONMessage.AddPair('role', 'system');
    JSONMessage.AddPair('content', 'Voce e um auditor fiscal experiente especializado em NF-e, CT-e e MDF-e. Responda sempre em JSON valido.');
    JSONMessages.Add(JSONMessage);

    JSONMessage := TJSONObject.Create;
    JSONMessage.AddPair('role', 'user');
    JSONMessage.AddPair('content', APrompt);
    JSONMessages.Add(JSONMessage);

    JSONRequest.AddPair('messages', JSONMessages);

    RequestBody := TStringStream.Create(JSONRequest.ToJSON, TEncoding.UTF8);
    try
      FHttpClient.CustomHeaders['Authorization'] := 'Bearer ' + FApiKey;
      Response := FHttpClient.Post(FEndpoint, RequestBody);
      if Response.StatusCode = 200 then
        Result := Response.ContentAsString
      else
        Result := '';
    finally
      RequestBody.Free;
    end;
  finally
    JSONRequest.Free;
  end;
end;

function TAIAnalyzer.ParseResponse(const AJson: string): TResultadoIA;
var
  JSONValue: TJSONValue;
  JSONObj: TJSONObject;
  Anomalias: TJSONValue;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Sucesso := False;

  JSONValue := TJSONObject.ParseJSONValue(AJson);
  if not Assigned(JSONValue) then Exit;

  try
    if JSONValue is TJSONObject then
    begin
      JSONObj := TJSONObject(JSONValue);
      Result.Confianca := 0.85;

      Anomalias := JSONObj.FindValue('anomalias');
      if Assigned(Anomalias) and (Anomalias is TJSONArray) then
        Result.AnomaliasEncontradas := TJSONArray(Anomalias).Count;

      Result.Sucesso := True;
    end;
  finally
    JSONValue.Free;
  end;
end;

function TAIAnalyzer.SimulateAnalysis(const ADocument: TFiscalDocument): TResultadoIA;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Sucesso := True;
  Result.Modelo := FModel + ' (simulacao)';
  Result.AnomaliasEncontradas := 0;

  if ADocument.ValorTotal > 50000 then
  begin
    Inc(Result.AnomaliasEncontradas);
    Result.Resposta := '[SIMULACAO] Valor acima de R$ 50.000,00 - verificar enquadramento fiscal.';
  end;

  if ADocument.DataEmissao < Now - 365 then
  begin
    Inc(Result.AnomaliasEncontradas);
    Result.Resposta := Result.Resposta + ' Documento emitido ha mais de 1 ano.';
  end;

  Result.Confianca := 0.85;
  if Result.AnomaliasEncontradas = 0 then
    Result.Resposta := '[SIMULACAO] Nenhuma anomalia fiscal detectada.';
end;

function TAIAnalyzer.AnalisarDocumento(const ADocument: TFiscalDocument): TResultadoIA;
var
  Prompt, RawResponse: string;
begin
  Prompt := BuildPrompt(ADocument);

  if FApiKey.IsEmpty then
  begin
    Result := SimulateAnalysis(ADocument);
    Result.Prompt := Prompt;
    Exit;
  end;

  RawResponse := CallDeepSeekAPI(Prompt);

  FillChar(Result, SizeOf(Result), 0);
  Result.Prompt := Prompt;
  Result.Modelo := FModel;

  if RawResponse.IsEmpty then
  begin
    Result := SimulateAnalysis(ADocument);
    Result.Prompt := Prompt;
    Result.Modelo := FModel + ' (erro API, usando simulacao)';
    Exit;
  end;

  Result.Resposta := RawResponse;
  Result := ParseResponse(RawResponse);
  Result.Resposta := RawResponse;
  Result.Prompt := Prompt;
  Result.Modelo := FModel;
  Result.Sucesso := True;
end;

end.
