using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VfiApi.Models;

public class DocumentItem
{
    [Key]
    public int Id { get; set; }

    public int DocumentId { get; set; }

    [Required, MaxLength(60)]
    public string ProductCode { get; set; } = string.Empty;

    [Required, MaxLength(200)]
    public string ProductName { get; set; } = string.Empty;

    [Required, MaxLength(8)]
    public string NCM { get; set; } = string.Empty;

    [Required, MaxLength(4)]
    public string CFOP { get; set; } = string.Empty;

    [Column(TypeName = "decimal(18,4)")]
    public decimal Quantity { get; set; }

    [Column(TypeName = "decimal(18,4)")]
    public decimal UnitValue { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal TotalValue { get; set; }

    [MaxLength(3)]
    public string? CST { get; set; }

    [ForeignKey(nameof(DocumentId))]
    public FiscalDocument? Document { get; set; }
}
