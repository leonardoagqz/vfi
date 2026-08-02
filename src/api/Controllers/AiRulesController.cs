using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VfiApi.Data;
using VfiApi.Models;

namespace VfiApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AiRulesController : ControllerBase
{
    private readonly VfiDbContext _context;

    public AiRulesController(VfiDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<AiRule>>> GetAiRules([FromQuery] bool activeOnly = false)
    {
        var query = _context.AiRules.AsQueryable();
        if (activeOnly)
        {
            query = query.Where(r => r.IsActive);
        }
        return await query.ToListAsync();
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<AiRule>> GetAiRule(int id)
    {
        var rule = await _context.AiRules.FindAsync(id);

        if (rule == null)
            return NotFound();

        return rule;
    }

    [HttpPost]
    public async Task<ActionResult<AiRule>> CreateAiRule(AiRule rule)
    {
        rule.CreatedAt = DateTime.UtcNow;
        _context.AiRules.Add(rule);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetAiRule), new { id = rule.Id }, rule);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateAiRule(int id, AiRule rule)
    {
        if (id != rule.Id)
            return BadRequest();

        _context.Entry(rule).State = EntityState.Modified;
        _context.Entry(rule).Property(x => x.CreatedAt).IsModified = false;
        rule.UpdatedAt = DateTime.UtcNow;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!AiRuleExists(id))
                return NotFound();
            else
                throw;
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteAiRule(int id)
    {
        var rule = await _context.AiRules.FindAsync(id);
        if (rule == null)
            return NotFound();

        // Soft delete
        rule.IsActive = false;
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private bool AiRuleExists(int id)
    {
        return _context.AiRules.Any(e => e.Id == id);
    }
}
