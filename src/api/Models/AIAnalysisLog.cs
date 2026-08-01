using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VfiApi.Models;

public class AIAnalysisLog
{
    [Key]
    public int Id { get; set; }

    public int DocumentId { get; set; }

    [Required, MaxLength(50)]
    public string Model { get; set; } = string.Empty;

    public string Prompt { get; set; } = string.Empty;

    public string? Response { get; set; }

    public int AnomaliesFound { get; set; }

    [Column(TypeName = "decimal(5,2)")]
    public decimal? ConfidenceScore { get; set; }

    public int? TokensUsed { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [ForeignKey(nameof(DocumentId))]
    public FiscalDocument? Document { get; set; }
}
