unit VFI.Services.AIAnalyzer;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient,
  System.Net.URLClient, System.JSON, System.StrUtils, System.Math,
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
var
  SB: TStringBuilder;
  Item: TDocumentItem;
  Count: Integer;
  TotalItens: Currency;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Sucesso := True;
  Result.Modelo := 'analise-fiscal-local';
  Count := 0;
  TotalItens := 0;
  SB := TStringBuilder.Create;
  try
    Result.Prompt := BuildPrompt(ADocument);
    SB.AppendLine(Format('Documento: %s #%s | %s | R$ %.2f',
      [TipoDocumentoToStr(ADocument.Tipo), ADocument.Numero, ADocument.NomeEmitente, ADocument.ValorTotal]));
    SB.AppendLine('');

    if ADocument.Itens.Count = 0 then
    begin
      SB.AppendLine('[ALERTA] Documento sem itens cadastrados.');
      Inc(Count);
    end;

    if ADocument.ValorTotal <= 0 then
    begin
      SB.AppendLine('[CRITICO] Valor total zerado - possivel erro de emissao ou XML incompleto.');
      Inc(Count);
    end;

    for Item in ADocument.Itens do
    begin
      TotalItens := TotalItens + Item.ValorTotal;

      if (Item.NCM = '') or (Item.NCM = '00000000') then
      begin
        SB.AppendLine(Format('[CRITICO] Item "%s": NCM nao informado ou invalido (%s).', [Item.NomeProduto, Item.NCM]));
        Inc(Count);
      end;

      if (Item.CFOP = '') or (StrToIntDef(Item.CFOP, 0) < 1000) or (StrToIntDef(Item.CFOP, 0) > 7999) then
      begin
        SB.AppendLine(Format('[CRITICO] Item "%s": CFOP invalido (%s). Deve estar entre 1000 e 7999.', [Item.NomeProduto, Item.CFOP]));
        Inc(Count);
      end
      else
      begin
        if Copy(Item.CFOP, 1, 1) = '6' then
          SB.AppendLine(Format('[INFO] CFOP %s (%s): operacao de entrada/aquisicao.', [Item.CFOP, Item.NomeProduto]));
      end;

      if Item.ValorUnitario > 10000 then
      begin
        SB.AppendLine(Format('[ATENCAO] Item "%s": valor unitario elevado (R$ %.2f).', [Item.NomeProduto, Item.ValorUnitario]));
        Inc(Count);
      end;

      if Item.ValorUnitario <= 0 then
      begin
        SB.AppendLine(Format('[CRITICO] Item "%s": valor unitario zerado.', [Item.NomeProduto]));
        Inc(Count);
      end;
    end;

    if (ADocument.Itens.Count > 0) and (Abs(TotalItens - ADocument.ValorTotal) > 0.01) then
    begin
      SB.AppendLine(Format('[CRITICO] Divergencia: soma dos itens = R$ %.2f, valor total do documento = R$ %.2f.',
        [TotalItens, ADocument.ValorTotal]));
      Inc(Count);
    end;

    if ADocument.ValorTotal > 50000 then
    begin
      SB.AppendLine('[ATENCAO] Valor total acima de R$ 50.000,00. Verificar ST e obrigacoes acessorias.');
      Inc(Count);
    end;

    if (ADocument.CnpjEmitente = '') or (Length(ADocument.CnpjEmitente) < 14) then
    begin
      SB.AppendLine('[CRITICO] CNPJ do emitente nao informado ou incompleto.');
      Inc(Count);
    end;

    if (ADocument.CnpjDestinatario = '') or (Length(ADocument.CnpjDestinatario) < 14) then
    begin
      SB.AppendLine('[CRITICO] CNPJ do destinatario nao informado ou incompleto.');
      Inc(Count);
    end;

    if (ADocument.CnpjEmitente <> '') and (ADocument.CnpjEmitente = ADocument.CnpjDestinatario) then
    begin
      SB.AppendLine('[ALERTA] Emitente e destinatario com o mesmo CNPJ.');
      Inc(Count);
    end;

    if ADocument.DataEmissao < Now - 365 then
    begin
      SB.AppendLine('[ATENCAO] Documento com mais de 1 ano. Verificar prescricao fiscal.');
      Inc(Count);
    end;

    if Count = 0 then
    begin
      SB.AppendLine('[OK] Nenhuma anomalia fiscal detectada na analise automatica.');
      Result.Confianca := 0.95;
    end
    else if Count <= 2 then
      Result.Confianca := 0.80
    else
      Result.Confianca := 0.65;

    SB.AppendLine('');
    SB.AppendLine(Format('Total: %d anomalia(s) | Confianca: %.0f%%', [Count, Result.Confianca * 100]));

    Result.AnomaliasEncontradas := Count;
    Result.Resposta := SB.ToString;
  finally
    SB.Free;
  end;
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
