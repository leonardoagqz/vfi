using Microsoft.EntityFrameworkCore;
using VfiApi.Models;

namespace VfiApi.Data;

public class VfiDbContext : DbContext
{
    public VfiDbContext(DbContextOptions<VfiDbContext> options) : base(options) { }

    public DbSet<FiscalDocument> FiscalDocuments => Set<FiscalDocument>();
    public DbSet<DocumentItem> DocumentItems => Set<DocumentItem>();
    public DbSet<TaxCalculation> TaxCalculations => Set<TaxCalculation>();
    public DbSet<ValidationLog> ValidationLogs => Set<ValidationLog>();
    public DbSet<AIAnalysisLog> AIAnalysisLogs => Set<AIAnalysisLog>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<FiscalDocument>(entity =>
        {
            entity.ToTable("FiscalDocument");
            entity.HasIndex(e => e.DocumentType);
            entity.HasIndex(e => e.IssuerCNPJ);
            entity.HasIndex(e => e.Status);
            entity.HasIndex(e => e.DocumentKey).IsUnique();
        });

        modelBuilder.Entity<DocumentItem>(entity =>
        {
            entity.ToTable("DocumentItem");
            entity.HasIndex(e => e.DocumentId);
            entity.HasOne(e => e.Document)
                  .WithMany(d => d.Items)
                  .HasForeignKey(e => e.DocumentId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<TaxCalculation>(entity =>
        {
            entity.ToTable("TaxCalculation");
            entity.HasIndex(e => e.DocumentId);
            entity.HasOne(e => e.Document)
                  .WithMany(d => d.TaxCalculations)
                  .HasForeignKey(e => e.DocumentId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<ValidationLog>(entity =>
        {
            entity.ToTable("ValidationLog");
            entity.HasOne(e => e.Document)
                  .WithMany(d => d.ValidationLogs)
                  .HasForeignKey(e => e.DocumentId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<AIAnalysisLog>(entity =>
        {
            entity.ToTable("AIAnalysisLog");
            entity.HasOne(e => e.Document)
                  .WithMany(d => d.AIAnalysisLogs)
                  .HasForeignKey(e => e.DocumentId)
                  .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
