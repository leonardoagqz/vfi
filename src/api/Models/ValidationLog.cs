using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace VfiApi.Models;

public class ValidationLog
{
    [Key]
    public int Id { get; set; }

    public int DocumentId { get; set; }

    [Required, MaxLength(30)]
    public string ValidationType { get; set; } = string.Empty;

    public bool IsValid { get; set; }

    [MaxLength(500)]
    public string? ErrorMessage { get; set; }

    [MaxLength(20)]
    public string? ErrorCode { get; set; }

    public DateTime ValidatedAt { get; set; } = DateTime.UtcNow;

    [ForeignKey(nameof(DocumentId))]
    public FiscalDocument? Document { get; set; }
}
