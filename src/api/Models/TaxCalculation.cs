using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VfiApi.Models;

public class TaxCalculation
{
    [Key]
    public int Id { get; set; }

    public int? DocumentId { get; set; }
    public int? ItemId { get; set; }

    [Required, MaxLength(10)]
    public string TaxType { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,2)")]
    public decimal TaxBase { get; set; }

    [Column(TypeName = "decimal(7,4)")]
    public decimal TaxRate { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal TaxValue { get; set; }

    [Required, MaxLength(20)]
    public string CalculationEngine { get; set; } = "VB6";

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [ForeignKey(nameof(DocumentId))]
    public FiscalDocument? Document { get; set; }

    [ForeignKey(nameof(ItemId))]
    public DocumentItem? Item { get; set; }
}
