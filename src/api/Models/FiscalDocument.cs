using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VfiApi.Models;

public class FiscalDocument
{
    [Key]
    public int Id { get; set; }

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

    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalValue { get; set; }

    public string? XMLContent { get; set; }

    [Required, MaxLength(20)]
    public string Status { get; set; } = "PENDENTE";

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<DocumentItem> Items { get; set; } = new List<DocumentItem>();
    public ICollection<TaxCalculation> TaxCalculations { get; set; } = new List<TaxCalculation>();
    public ICollection<ValidationLog> ValidationLogs { get; set; } = new List<ValidationLog>();
    public ICollection<AIAnalysisLog> AIAnalysisLogs { get; set; } = new List<AIAnalysisLog>();
}
