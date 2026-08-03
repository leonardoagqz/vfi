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
    FRegrasFiscais: string;
    function BuildPrompt(const ADocument: TFiscalDocument): string;
    function CallDeepSeekAPI(const APrompt: string): string;
    function ParseResponse(const AJson: string): TResultadoIA;
    function SimulateAnalysis(const ADocument: TFiscalDocument): TResultadoIA;
  public
    constructor Create(const AApiKey, AEndpoint, AModel: string);
    destructor Destroy; override;
    function AnalisarDocumento(const ADocument: TFiscalDocument): TResultadoIA;
    procedure SetRegrasFiscais(const ARegras: string);
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
    SB.AppendLine(Format('Emitente: %s (%s) - %s/%s', [ADocument.NomeEmitente, ADocument.CnpjEmitente, ADocument.MunicipioEmitente, ADocument.UFEmitente]));
    SB.AppendLine(Format('Destinatario: %s (%s) - %s/%s', [ADocument.NomeDestinatario, ADocument.CnpjDestinatario, ADocument.MunicipioDestinatario, ADocument.UFDestinatario]));
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
    SB.AppendLine('Identifique anomalias fiscais neste documento.');
    if FRegrasFiscais <> '' then
    begin
      SB.AppendLine;
      SB.AppendLine('REGRAS FISCAIS DE REFERENCIA (use APENAS estas regras para validar):');
      SB.AppendLine(Copy(FRegrasFiscais, 1, 2000));
    end;
    SB.AppendLine;
    SB.AppendLine('Responda em JSON: {"anomalias":[{"tipo":"CRITICO|ALERTA|INFO","descricao":"...","proceder":"...","fontes":"..."}],"confianca":0.0-1.0}');

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
  JSONObj, AnomaliaItem: TJSONObject;
  Anomalias: TJSONValue;
  I: Integer;
  SB: TStringBuilder;
  Tipo, Descricao, Proceder, Fontes: string;
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
      
      var ConfNode := JSONObj.FindValue('confianca');
      if Assigned(ConfNode) and (ConfNode is TJSONNumber) then
        Result.Confianca := TJSONNumber(ConfNode).AsDouble;

      Anomalias := JSONObj.FindValue('anomalias');
      if Assigned(Anomalias) and (Anomalias is TJSONArray) then
      begin
        Result.AnomaliasEncontradas := TJSONArray(Anomalias).Count;
        SB := TStringBuilder.Create;
        try
          if Result.AnomaliasEncontradas = 0 then
            SB.AppendLine('Nenhuma anomalia encontrada. Documento parece estar em conformidade.')
          else
          begin
            for I := 0 to TJSONArray(Anomalias).Count - 1 do
            begin
              AnomaliaItem := TJSONObject(TJSONArray(Anomalias).Items[I]);
              Tipo := ''; Descricao := ''; Proceder := ''; Fontes := '';
              
              if Assigned(AnomaliaItem.FindValue('tipo')) then Tipo := AnomaliaItem.GetValue<string>('tipo');
              if Assigned(AnomaliaItem.FindValue('descricao')) then Descricao := AnomaliaItem.GetValue<string>('descricao');
              if Assigned(AnomaliaItem.FindValue('proceder')) then Proceder := AnomaliaItem.GetValue<string>('proceder');
              if Assigned(AnomaliaItem.FindValue('fontes')) then Fontes := AnomaliaItem.GetValue<string>('fontes');

              SB.AppendLine(Format('[%s]', [Tipo]));
              SB.AppendLine(Format('O que houve: %s', [Descricao]));
              if Proceder <> '' then SB.AppendLine(Format('Como proceder: %s', [Proceder]));
              if Fontes <> '' then SB.AppendLine(Format('Base Legal / Fontes: %s', [Fontes]));
              SB.AppendLine('');
            end;
          end;
          Result.Resposta := SB.ToString;
        finally
          SB.Free;
        end;
      end;

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
  TotalItens, Diferenca: Currency;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Sucesso := True;
  Result.Modelo := 'analise-fiscal-local';
  Count := 0;
  TotalItens := 0;
  SB := TStringBuilder.Create;
  try
    for Item in ADocument.Itens do
      TotalItens := TotalItens + Item.ValorTotal;

    case ADocument.Tipo of
      tdNFe:
      begin
        if (ADocument.Itens.Count > 0) and (Abs(TotalItens - ADocument.ValorTotal) > 0.01) then
        begin
          Diferenca := Abs(TotalItens - ADocument.ValorTotal);
          SB.AppendLine('[CRITICO]');
          SB.AppendLine('O que houve: Divergencia Financeira Detectada.');
          SB.AppendLine(Format('O somatorio do valor dos itens (R$ %.2f) nao bate com o Valor Total declarado na nota (R$ %.2f). Foi encontrada uma diferenca de R$ %.2f.', [TotalItens, ADocument.ValorTotal, Diferenca]));
          SB.AppendLine('Por que esta errado? A SEFAZ valida os totais da NF-e com base na soma exata dos itens e fretes/descontos. Se os valores nao baterem, a nota pode ser considerada invalida ou gerar suspeita de sonegacao.');
          SB.AppendLine('Como proceder: Verifique se houve aplicacao de descontos globais, frete ou seguro que nao foram rateados corretamente entre os itens. A nota devera ser corrigida e reenviada se ainda estiver em prazo de cancelamento/correcao.');
          SB.AppendLine('Base Legal / Fontes: Ajuste SINIEF 07/05 e Manual de Orientacao do Contribuinte (MOC) - Regras Gerais de Validacao da NF-e.');
          SB.AppendLine('');
          Inc(Count);
        end;

        for Item in ADocument.Itens do
        begin
          if Copy(Item.CFOP, 1, 1) = '6' then
          begin
            SB.AppendLine('[ATENCAO]');
            SB.AppendLine(Format('O que houve: Operacao Interestadual - CFOP %s (%s).', [Item.CFOP, Item.NomeProduto]));
            SB.AppendLine('Por que chama atencao? Codigos CFOP iniciados em 6 indicam operacoes fora do estado (interestaduais). Essas operacoes possuem regramento especifico de partilha de ICMS (DIFAL) ou cobranca por Substituicao Tributaria (ST), dependendo se o destino final for contribuinte ou consumidor final.');
            SB.AppendLine('Como proceder: Confirme se o emitente fez o calculo do Diferencial de Aliquota (DIFAL) ou se a mercadoria esta sujeita a convenio ICMS entre os dois estados. Se for ST, valide a GNRE.');
            SB.AppendLine('Base Legal / Fontes: Convenio ICMS 93/2015 e Lei Complementar 87/96 (Lei Kandir).');
            SB.AppendLine('');
            Inc(Count);
          end;

          if Item.ValorUnitario > 10000 then
          begin
            SB.AppendLine('[ATENCAO]');
            SB.AppendLine(Format('O que houve: Item com valor atipico (%s - R$ %.2f - NCM %s).',
              [Item.NomeProduto, Item.ValorUnitario, Item.NCM]));
            SB.AppendLine('Por que chama atencao? O valor unitario deste produto excede R$ 10.000,00, o que e incomum para categorias de bens de consumo padrao e pode apontar para erro de multiplicador de quantidade (venda por lote/peso). A fiscalizacao mapeia "subfaturamento" ou "superfaturamento" cruzando a NCM com a Base de Precos de Referencia.');
            SB.AppendLine('Como proceder: Verifique se a "Unidade Comercial" (ex: UN, CX, TON) no XML corresponde corretamente ao produto faturado. Caso esteja correto, nao ha risco.');
            SB.AppendLine('Base Legal / Fontes: Malha Fina da SEFAZ - Cruzamento de Precos de Referencia por NCM.');
            SB.AppendLine('');
            Inc(Count);
          end;

          if (Copy(Item.NCM, 1, 2) = '85') and (Copy(Item.CFOP, 1, 1) = '5') then
          begin
            SB.AppendLine('[INFO]');
            SB.AppendLine(Format('O que houve: Produto eletronico (NCM %s) faturado internamente (CFOP %s).', [Item.NCM, Item.CFOP]));
            SB.AppendLine('Por que chama atencao? Itens com NCM 85 (Maquinas, aparelhos e materiais eletricos) possuem vasta aplicacao de ICMS-ST (Substituicao Tributaria) em quase todos os estados brasileiros.');
            SB.AppendLine('Como proceder: Verifique se a tag CST/CSOSN do item indica ST (ex: CST 10, 30 ou 70). Se o item for revenda para consumidor final, certifique-se de que a cadeia ST esta encerrada adequadamente.');
            SB.AppendLine('Base Legal / Fontes: Convenio ICMS 142/2018 (Normas gerais da Substituicao Tributaria).');
            SB.AppendLine('');
            Inc(Count);
          end;
        end;

        if ADocument.ValorTotal > 50000 then
        begin
          SB.AppendLine('[ATENCAO]');
          SB.AppendLine('O que houve: NF-e com Valor Total elevado (Acima de R$ 50.000,00).');
          SB.AppendLine('Por que chama atencao? Movimentacoes rodoviarias acima deste teto, em especial interestaduais, tem rigorosa exigencia de acobertamento por MDF-e (Manifesto Eletronico) e risco de fiscalizacao de transito por postos fiscais.');
          SB.AppendLine('Como proceder: Confirme se a transportadora ou o proprio emissor vinculou esta NF-e a um MDF-e emitido na mesma data, prevenindo multas na rodovia.');
          SB.AppendLine('Base Legal / Fontes: Ajuste SINIEF 21/2010 (Obrigatoriedade do MDF-e).');
          SB.AppendLine('');
          Inc(Count);
        end;

        if ADocument.Itens.Count = 0 then
        begin
          SB.AppendLine('[CRITICO]');
          SB.AppendLine('O que houve: NF-e vazia - O documento nao contem nenhum item cadastrado.');
          SB.AppendLine('Por que esta errado? Uma Nota Fiscal Eletronica obrigatoriamente deve listar ao menos 1 item movimentado, mesmo que seja brinde ou amostra gratis, exceto em casos de NF-e complementar de imposto (que deve ter configuracoes exclusivas de CFOP/CST).');
          SB.AppendLine('Como proceder: Provavel falha estrutural no XML recebido ou na importacao. A nota e invalida para uso fiscal normal.');
          SB.AppendLine('Base Legal / Fontes: Manual de Orientacao do Contribuinte (MOC) - Preenchimento do XML.');
          SB.AppendLine('');
          Inc(Count);
        end;
      end;

      tdCTe:
      begin
        // CT-e Specific Rules
        if (ADocument.UFEmitente <> '') and (ADocument.UFDestinatario <> '') and 
           (ADocument.UFEmitente = ADocument.UFDestinatario) and (ADocument.ValorTotal > 15000) then
        begin
          SB.AppendLine('[ATENCAO]');
          SB.AppendLine(Format('O que houve: CT-e de alto valor (R$ %.2f) operando internamente no estado (%s).', [ADocument.ValorTotal, ADocument.UFEmitente]));
          SB.AppendLine('Por que chama atencao? Valores de frete interno muito elevados sugerem transporte de carga de altissimo valor agregado ou falha no multiplicador da tarifa de transporte. Cargas milionarias internas exigem seguros reforcados (RCTR-C).');
          SB.AppendLine('Como proceder: Valide as apolices de seguro associadas a este CT-e e confirme o calculo tarifario (tonelagem vs pedagios).');
          SB.AppendLine('Base Legal / Fontes: Regulamento de Transporte Rodoviario de Cargas (ANTT) e regras de averbacao de seguro.');
          SB.AppendLine('');
          Inc(Count);
        end;

        if ADocument.Itens.Count = 0 then
        begin
          SB.AppendLine('[INFO]');
          SB.AppendLine('O que houve: CT-e sem composicao de carga detalhada.');
          SB.AppendLine('Por que chama atencao? Embora o CT-e normal nao exija o cadastro de itens detalhados (produtos), ele exige as chaves de acesso das NF-es vinculadas, que definem a natureza da carga transportada.');
          SB.AppendLine('Como proceder: Certifique-se de que a lista de NF-es (chaves de 44 digitos) foi importada com sucesso no CT-e e corresponde ao romaneio de transporte logistico para evitar apreensao na barreira.');
          SB.AppendLine('Base Legal / Fontes: Ajuste SINIEF 09/2007 (Institui o Conhecimento de Transporte Eletronico).');
          SB.AppendLine('');
          Inc(Count);
        end;
      end;
    end;

    if Count = 0 then
    begin
      SB.AppendLine('Nenhuma anomalia encontrada. O documento parece estar em conformidade e nao exige acao.');
      Result.Confianca := 0.95;
    end
    else if Count <= 2 then
      Result.Confianca := 0.85
    else
      Result.Confianca := 0.65;

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

  Result := ParseResponse(RawResponse);
  Result.Prompt := Prompt;
  Result.Modelo := FModel;
  Result.Sucesso := True;
end;

procedure TAIAnalyzer.SetRegrasFiscais(const ARegras: string);
begin
  FRegrasFiscais := ARegras;
end;

end.
