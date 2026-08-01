using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VfiApi.Data;
using VfiApi.DTOs;
using VfiApi.Models;
using VfiApi.Services;

namespace VfiApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FiscalDocumentsController : ControllerBase
{
    private readonly VfiDbContext _db;
    private readonly FiscalValidationService _validator;
    private readonly IAIntegrationService _ia;

    public FiscalDocumentsController(VfiDbContext db, FiscalValidationService validator, IAIntegrationService ia)
    {
        _db = db;
        _validator = validator;
        _ia = ia;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<FiscalDocument>>> GetAll(
        [FromQuery] string? type, [FromQuery] string? status, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var query = _db.FiscalDocuments.Include(d => d.Items).AsQueryable();

        if (!string.IsNullOrWhiteSpace(type))
            query = query.Where(d => d.DocumentType == type);
        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(d => d.Status == status);

        var items = await query
            .OrderByDescending(d => d.IssueDate)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        var total = await query.CountAsync();

        Response.Headers.Append("X-Total-Count", total.ToString());
        return Ok(items);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<FiscalDocument>> GetById(int id)
    {
        var doc = await _db.FiscalDocuments
            .Include(d => d.Items)
            .Include(d => d.TaxCalculations)
            .Include(d => d.ValidationLogs)
            .Include(d => d.AIAnalysisLogs)
            .FirstOrDefaultAsync(d => d.Id == id);

        if (doc == null) return NotFound();
        return Ok(doc);
    }

    [HttpPost]
    public async Task<ActionResult<FiscalDocument>> Create([FromBody] FiscalDocumentDto dto)
    {
        var document = new FiscalDocument
        {
            DocumentType = dto.DocumentType,
            DocumentKey = dto.DocumentKey,
            DocumentNumber = dto.DocumentNumber,
            IssueDate = dto.IssueDate,
            IssuerCNPJ = dto.IssuerCNPJ,
            IssuerName = dto.IssuerName,
            RecipientCNPJ = dto.RecipientCNPJ,
            RecipientName = dto.RecipientName,
            TotalValue = dto.TotalValue,
            XMLContent = dto.XMLContent,
            Items = dto.Items.Select(i => new DocumentItem
            {
                ProductCode = i.ProductCode,
                ProductName = i.ProductName,
                NCM = i.NCM,
                CFOP = i.CFOP,
                Quantity = i.Quantity,
                UnitValue = i.UnitValue,
                TotalValue = i.TotalValue,
                CST = i.CST
            }).ToList()
        };

        _db.FiscalDocuments.Add(document);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetById), new { id = document.Id }, document);
    }

    [HttpPost("{id}/validate")]
    public async Task<ActionResult<ValidationResponse>> Validate(int id)
    {
        var doc = await _db.FiscalDocuments.Include(d => d.Items).FirstOrDefaultAsync(d => d.Id == id);
        if (doc == null) return NotFound();

        var result = _validator.ValidateDocument(doc);

        var log = new ValidationLog
        {
            DocumentId = doc.Id,
            ValidationType = "COMPLETE",
            IsValid = result.IsValid,
            ErrorMessage = result.IsValid ? null : string.Join("; ", result.Errors.Select(e => e.Message)),
            ErrorCode = result.IsValid ? null : result.Errors.FirstOrDefault()?.Code
        };

        doc.Status = result.IsValid ? "VALIDADO" : "REJEITADO";
        doc.UpdatedAt = DateTime.UtcNow;

        _db.ValidationLogs.Add(log);
        await _db.SaveChangesAsync();

        return Ok(result);
    }

    [HttpPost("{id}/analyze-ai")]
    public async Task<ActionResult<AIAnalysisLog>> AnalyzeWithAI(int id, [FromBody] AIAnalysisRequest? request)
    {
        var doc = await _db.FiscalDocuments.Include(d => d.Items).FirstOrDefaultAsync(d => d.Id == id);
        if (doc == null) return NotFound();

        var log = await _ia.AnalyzeDocumentAsync(doc, request?.ModelOverride);

        _db.AIAnalysisLogs.Add(log);
        await _db.SaveChangesAsync();

        return Ok(log);
    }

    [HttpPost("{id}/calculate-tax")]
    public async Task<ActionResult<TaxCalculation>> CalculateTax(int id, [FromBody] TaxCalculationRequest request)
    {
        var doc = await _db.FiscalDocuments.FirstOrDefaultAsync(d => d.Id == id);
        if (doc == null) return NotFound();

        var calc = new TaxCalculation
        {
            DocumentId = id,
            ItemId = request.ItemId,
            TaxType = request.TaxType,
            TaxBase = request.ProductValue + request.Freight + request.Insurance + request.OtherExpenses - request.Discount,
            TaxRate = request.TaxRate,
            TaxValue = (request.ProductValue + request.Freight + request.Insurance + request.OtherExpenses - request.Discount) * (request.TaxRate / 100),
            CalculationEngine = "INTERNAL"
        };

        calc.TaxValue = Math.Round(calc.TaxValue, 2);

        _db.TaxCalculations.Add(calc);
        await _db.SaveChangesAsync();

        return Ok(calc);
    }
}
