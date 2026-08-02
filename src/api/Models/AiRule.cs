namespace VfiApi.Models;

public class AiRule
{
    public int Id { get; set; }
    public string Description { get; set; } = string.Empty;
    public string? Severity { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}
