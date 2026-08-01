using System.ComponentModel.DataAnnotations;

namespace VfiApi.DTOs;

public class FiscalDocumentDto
{
    [Required, MaxLength(20)]
    public string DocumentType { get; set; } = string.Empty;

    [Required, MaxLength(44)]
    public string DocumentKey { get; set; } = string.Empty;

    [Required, MaxLength(20)]
    public string DocumentNumber { get; set; } = string.Empty;

    public DateTime IssueDate { get; set; }

    [Required, MaxLength(14)]
    public string IssuerCNPJ { get; set; } = string.Empty;

    [Required, MaxLength(200)]
    public string IssuerName { get; set; } = string.Empty;

    [Required, MaxLength(14)]
    public string RecipientCNPJ { get; set; } = string.Empty;

    [Required, MaxLength(200)]
    public string RecipientName { get; set; } = string.Empty;

    public decimal TotalValue { get; set; }

    public string? XMLContent { get; set; }

    public List<DocumentItemDto> Items { get; set; } = new();
}

public class DocumentItemDto
{
    [Required, MaxLength(60)]
    public string ProductCode { get; set; } = string.Empty;

    [Required, MaxLength(200)]
    public string ProductName { get; set; } = string.Empty;

    [Required, MaxLength(8)]
    public string NCM { get; set; } = string.Empty;

    [Required, MaxLength(4)]
    public string CFOP { get; set; } = string.Empty;

    public decimal Quantity { get; set; }
    public decimal UnitValue { get; set; }
    public decimal TotalValue { get; set; }

    [MaxLength(3)]
    public string? CST { get; set; }
}

public class TaxCalculationRequest
{
    public int DocumentId { get; set; }
    public int? ItemId { get; set; }
    public string TaxType { get; set; } = string.Empty;
    public decimal ProductValue { get; set; }
    public decimal TaxRate { get; set; }
    public decimal Freight { get; set; }
    public decimal Insurance { get; set; }
    public decimal OtherExpenses { get; set; }
    public decimal Discount { get; set; }
}

public class AIAnalysisRequest
{
    public int DocumentId { get; set; }
    public string? ModelOverride { get; set; }
}

public class ValidationResponse
{
    public int DocumentId { get; set; }
    public bool IsValid { get; set; }
    public List<ValidationError> Errors { get; set; } = new();
}

public class ValidationError
{
    public string Code { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Field { get; set; } = string.Empty;
}
