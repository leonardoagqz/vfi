using System.Text;
using System.Text.Json;
using VfiApi.Models;

namespace VfiApi.Services;

public class IAIntegrationService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly ILogger<IAIntegrationService> _logger;

    public IAIntegrationService(HttpClient httpClient, IConfiguration configuration, ILogger<IAIntegrationService> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<AIAnalysisLog> AnalyzeDocumentAsync(FiscalDocument document, string? modelOverride = null)
    {
        var model = modelOverride ?? _configuration["AI:Model"] ?? "gpt-4o-mini";
        var prompt = BuildAnalysisPrompt(document);

        var log = new AIAnalysisLog
        {
            DocumentId = document.Id,
            Model = model,
            Prompt = prompt
        };

        try
        {
            var apiKey = _configuration["AI:ApiKey"];
            var endpoint = _configuration["AI:Endpoint"] ?? "https://api.openai.com/v1/chat/completions";

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                log.Response = "[SIMULACAO] Chave de API nao configurada. Analise simulada.";
                log.AnomaliesFound = SimulateAnomalyDetection(document);
                log.ConfidenceScore = 0.75m;
                return log;
            }

            var requestBody = new
            {
                model,
                messages = new[]
                {
                    new { role = "system", content = "Voce e um auditor fiscal experiente especializado em NF-e, CT-e e MDF-e. Analise documentos fiscais e identifique anomalias, inconsistencias e riscos." },
                    new { role = "user", content = prompt }
                },
                temperature = 0.3,
                max_tokens = 1000
            };

            var json = JsonSerializer.Serialize(requestBody);
            var content = new StringContent(json, Encoding.UTF8, "application/json");

            if (!string.IsNullOrWhiteSpace(apiKey))
                _httpClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", apiKey);

            var response = await _httpClient.PostAsync(endpoint, content);
            response.EnsureSuccessStatusCode();

            var responseBody = await response.Content.ReadAsStringAsync();
            log.Response = responseBody;

            using var doc = JsonDocument.Parse(responseBody);
            var choice = doc.RootElement.GetProperty("choices")[0];
            var message = choice.GetProperty("message").GetProperty("content").GetString();

            log.AnomaliesFound = CountAnomaliesInResponse(message ?? "");
            log.ConfidenceScore = 0.85m;
            log.TokensUsed = doc.RootElement.GetProperty("usage").GetProperty("total_tokens").GetInt32();
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Erro ao chamar API de IA. Usando simulacao.");
            log.Response = $"[ERRO] {ex.Message}. Analise simulada ativada.";
            log.AnomaliesFound = SimulateAnomalyDetection(document);
            log.ConfidenceScore = 0.65m;
        }

        return log;
    }

    private static string BuildAnalysisPrompt(FiscalDocument document)
    {
        var sb = new StringBuilder();
        sb.AppendLine("Analise o seguinte documento fiscal:");
        sb.AppendLine($"Tipo: {document.DocumentType}");
        sb.AppendLine($"Chave: {document.DocumentKey}");
        sb.AppendLine($"Numero: {document.DocumentNumber}");
        sb.AppendLine($"Emitente: {document.IssuerName} (CNPJ: {document.IssuerCNPJ})");
        sb.AppendLine($"Destinatario: {document.RecipientName} (CNPJ: {document.RecipientCNPJ})");
        sb.AppendLine($"Valor Total: R$ {document.TotalValue:F2}");
        sb.AppendLine($"Data: {document.IssueDate:dd/MM/yyyy}");
        sb.AppendLine();

        sb.AppendLine("Itens:");
        foreach (var item in document.Items)
        {
            sb.AppendLine($"- {item.ProductCode}: {item.ProductName}, Qtd: {item.Quantity}, Valor: R$ {item.TotalValue:F2}, NCM: {item.NCM}, CFOP: {item.CFOP}");
        }

        sb.AppendLine();
        sb.AppendLine("Identifique:");
        sb.AppendLine("1. Inconsistencias nos valores calculados");
        sb.AppendLine("2. CFOP incompativel com NCM");
        sb.AppendLine("3. Valores suspeitos ou fora do padrao");
        sb.AppendLine("4. Problemas de enquadramento fiscal");
        sb.AppendLine("Responda em formato JSON com anomalias encontradas.");

        return sb.ToString();
    }

    private static int CountAnomaliesInResponse(string response)
    {
        if (string.IsNullOrWhiteSpace(response)) return 0;
        int count = 0;
        foreach (var keyword in new[] { "anomalia", "inconsistencia", "irregularidade", "erro", "divergencia", "suspeito" })
            count += CountOccurrences(response.ToLowerInvariant(), keyword);
        return Math.Min(count, 10);
    }

    private static int CountOccurrences(string text, string search)
    {
        int count = 0, index = 0;
        while ((index = text.IndexOf(search, index, StringComparison.Ordinal)) != -1)
        {
            count++;
            index += search.Length;
        }
        return count;
    }

    private static int SimulateAnomalyDetection(FiscalDocument document)
    {
        int anomalies = 0;
        if (document.TotalValue > 100000) anomalies++;
        if (document.IssueDate < DateTime.UtcNow.AddDays(-365)) anomalies++;
        if (document.DocumentType == "NFe" && document.TotalValue > 50000) anomalies++;
        return anomalies;
    }
}
