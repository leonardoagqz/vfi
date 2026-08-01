using VfiApi.DTOs;
using VfiApi.Services;

namespace VfiApi.Tests;

public class FiscalValidationServiceTests
{
    [Fact]
    public void ValidateCNPJ_Valid_ReturnsTrue()
    {
        Assert.True(FiscalValidationService.ValidateCNPJ("11222333000181"));
    }

    [Fact]
    public void ValidateCNPJ_Invalid_ReturnsFalse()
    {
        Assert.False(FiscalValidationService.ValidateCNPJ("11222333000182"));
    }

    [Fact]
    public void ValidateCNPJ_WrongLength_ReturnsFalse()
    {
        Assert.False(FiscalValidationService.ValidateCNPJ("12345"));
        Assert.False(FiscalValidationService.ValidateCNPJ(""));
    }

    [Fact]
    public void ValidateNCM_Valid_ReturnsTrue()
    {
        Assert.True(FiscalValidationService.ValidateNCM("84714900"));
        Assert.True(FiscalValidationService.ValidateNCM("48201000"));
    }

    [Fact]
    public void ValidateNCM_Invalid_ReturnsFalse()
    {
        Assert.False(FiscalValidationService.ValidateNCM("12345"));
        Assert.False(FiscalValidationService.ValidateNCM("ABCDEFGH"));
    }

    [Fact]
    public void ValidateCFOP_Valid_ReturnsTrue()
    {
        Assert.True(FiscalValidationService.ValidateCFOP("5101"));
        Assert.True(FiscalValidationService.ValidateCFOP("6102"));
    }

    [Fact]
    public void ValidateCFOP_Invalid_ReturnsFalse()
    {
        Assert.False(FiscalValidationService.ValidateCFOP("9999"));
        Assert.False(FiscalValidationService.ValidateCFOP("ABCD"));
        Assert.False(FiscalValidationService.ValidateCFOP("99999"));
    }

    [Fact]
    public void ValidateDocument_WithInvalidCNPJ_ReturnsErrors()
    {
        var service = new FiscalValidationService();
        var document = new Models.FiscalDocument
        {
            Id = 1,
            DocumentType = "NFe",
            DocumentKey = "35240112345678901234567890123456789012345678",
            DocumentNumber = "000001001",
            IssuerCNPJ = "12345",
            IssuerName = "Teste",
            RecipientCNPJ = "11222333000181",
            RecipientName = "Destino",
            TotalValue = 1000,
            IssueDate = DateTime.UtcNow.AddDays(-1),
            Items = new List<Models.DocumentItem>
            {
                new Models.DocumentItem { ProductCode = "P001", ProductName = "Produto", NCM = "84714900", CFOP = "5101", Quantity = 1, UnitValue = 1000, TotalValue = 1000 }
            }
        };

        var result = service.ValidateDocument(document);
        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.Code == "E002");
    }

    [Fact]
    public void ValidateDocument_Valid_ReturnsNoErrors()
    {
        var service = new FiscalValidationService();
        var document = new Models.FiscalDocument
        {
            Id = 1,
            DocumentType = "NFe",
            DocumentKey = "35240112345678901234567890123456789012345678",
            DocumentNumber = "000001001",
            IssuerCNPJ = "11222333000181",
            IssuerName = "Teste",
            RecipientCNPJ = "11222333000181",
            RecipientName = "Destino",
            TotalValue = 1000,
            IssueDate = DateTime.UtcNow.AddDays(-1),
            Items = new List<Models.DocumentItem>
            {
                new Models.DocumentItem { ProductCode = "P001", ProductName = "Produto", NCM = "84714900", CFOP = "5101", Quantity = 1, UnitValue = 1000, TotalValue = 1000 }
            }
        };

        var result = service.ValidateDocument(document);
        Assert.True(result.IsValid);
    }

    [Fact]
    public void ValidateDocument_WithBadXML_ReturnsError()
    {
        var service = new FiscalValidationService();
        var document = new Models.FiscalDocument
        {
            Id = 1,
            DocumentType = "NFe",
            DocumentKey = "35240112345678901234567890123456789012345678",
            DocumentNumber = "000001001",
            IssuerCNPJ = "11222333000181",
            IssuerName = "Teste",
            RecipientCNPJ = "11222333000181",
            RecipientName = "Destino",
            TotalValue = 1000,
            IssueDate = DateTime.UtcNow.AddDays(-1),
            XMLContent = "xml malformado<<<>>>",
            Items = new List<Models.DocumentItem>
            {
                new Models.DocumentItem { ProductCode = "P001", ProductName = "Produto", NCM = "84714900", CFOP = "5101", Quantity = 1, UnitValue = 1000, TotalValue = 1000 }
            }
        };

        var result = service.ValidateDocument(document);
        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.Code == "E020");
    }
}
