using System.Text;
using System.Text.Json;
using System.Xml.Linq;
using VfiApi.DTOs;
using VfiApi.Models;

namespace VfiApi.Services;

public class FiscalValidationService
{
    public ValidationResponse ValidateDocument(FiscalDocument document)
    {
        var response = new ValidationResponse { DocumentId = document.Id, IsValid = true };

        if (string.IsNullOrWhiteSpace(document.DocumentKey) || document.DocumentKey.Length != 44)
            response.Errors.Add(new ValidationError { Code = "E001", Field = "DocumentKey", Message = "Chave do documento fiscal deve ter 44 digitos" });

        if (!ValidateCNPJ(document.IssuerCNPJ))
            response.Errors.Add(new ValidationError { Code = "E002", Field = "IssuerCNPJ", Message = "CNPJ do emitente invalido" });

        if (!ValidateCNPJ(document.RecipientCNPJ))
            response.Errors.Add(new ValidationError { Code = "E003", Field = "RecipientCNPJ", Message = "CNPJ do destinatario invalido" });

        if (document.TotalValue <= 0)
            response.Errors.Add(new ValidationError { Code = "E004", Field = "TotalValue", Message = "Valor total deve ser maior que zero" });

        if (document.IssueDate > DateTime.UtcNow.AddDays(1))
            response.Errors.Add(new ValidationError { Code = "E005", Field = "IssueDate", Message = "Data de emissao nao pode ser futura" });

        foreach (var item in document.Items)
        {
            if (!ValidateNCM(item.NCM))
                response.Errors.Add(new ValidationError { Code = "E010", Field = "NCM", Message = $"NCM invalido para produto {item.ProductCode}" });

            if (!ValidateCFOP(item.CFOP))
                response.Errors.Add(new ValidationError { Code = "E011", Field = "CFOP", Message = $"CFOP invalido para produto {item.ProductCode}" });

            if (item.Quantity <= 0)
                response.Errors.Add(new ValidationError { Code = "E012", Field = "Quantity", Message = $"Quantidade invalida para produto {item.ProductCode}" });
        }

        if (!string.IsNullOrWhiteSpace(document.XMLContent))
        {
            try
            {
                XDocument.Parse(document.XMLContent);
            }
            catch
            {
                response.Errors.Add(new ValidationError { Code = "E020", Field = "XMLContent", Message = "XML mal formado" });
            }
        }

        response.IsValid = response.Errors.Count == 0;
        return response;
    }

    public static bool ValidateCNPJ(string cnpj)
    {
        if (string.IsNullOrWhiteSpace(cnpj)) return false;
        var digits = new string(cnpj.Where(char.IsDigit).ToArray());
        if (digits.Length != 14) return false;

        int[] multiplier1 = { 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };
        int[] multiplier2 = { 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };

        int sum = 0;
        for (int i = 0; i < 12; i++) sum += (digits[i] - '0') * multiplier1[i];
        int remainder = sum % 11;
        int digit1 = remainder < 2 ? 0 : 11 - remainder;
        if (digit1 != (digits[12] - '0')) return false;

        sum = 0;
        for (int i = 0; i < 13; i++) sum += (digits[i] - '0') * multiplier2[i];
        remainder = sum % 11;
        int digit2 = remainder < 2 ? 0 : 11 - remainder;
        return digit2 == (digits[13] - '0');
    }

    public static bool ValidateNCM(string ncm) =>
        !string.IsNullOrWhiteSpace(ncm) && ncm.Length == 8 && ncm.All(char.IsDigit);

    public static bool ValidateCFOP(string cfop)
    {
        if (string.IsNullOrWhiteSpace(cfop) || cfop.Length != 4) return false;
        if (!int.TryParse(cfop, out int value)) return false;
        return value >= 1000 && value <= 7999;
    }
}
