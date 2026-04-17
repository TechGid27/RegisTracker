using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Doctrack_backend_api.Data;
using Doctrack_backend_api.Models;

namespace Doctrack_backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")] // Only admins can seed data
public class SeedController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<SeedController> _logger;

    public SeedController(ApplicationDbContext context, ILogger<SeedController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// POST: api/Seed/document-types - Seed common document types
    /// </summary>
    [HttpPost("document-types")]
    public async Task<IActionResult> SeedDocumentTypes()
    {
        try
        {
            // Documents Requiring Payment
            var documentTypes = new List<DocumentType>
            {
                // Academic Records (Requiring Payment)
                new DocumentType
                {
                    Name = "Form 137 (Permanent Record/Transcript)",
                    Description = "Permanent academic record/transcript - Requires payment",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 5,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new DocumentType
                {
                    Name = "Form 138 (Report Card)",
                    Description = "Official report card - Requires payment",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 3,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new DocumentType
                {
                    Name = "Transcript of Records (TOR)",
                    Description = "Official academic transcript - Requires payment",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 5,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                
                // Certificates (Requiring Payment)
                new DocumentType
                {
                    Name = "Good Moral Character Certificate",
                    Description = "Certificate of good moral character - Requires payment",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 3,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new DocumentType
                {
                    Name = "Certificate of Graduation",
                    Description = "Official graduation certificate - Requires payment",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 5,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new DocumentType
                {
                    Name = "Other Certificates",
                    Description = "All other certificates - Requires payment",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 3,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                
                // Transfer Credentials (Requiring Payment)
                new DocumentType
                {
                    Name = "Honorable Dismissal",
                    Description = "Transfer credential for students moving to another institution - Requires payment",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 5,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                
                // College Documents (Requiring Payment)
                new DocumentType
                {
                    Name = "Summary of Grades",
                    Description = "Summary of academic grades - Requires payment",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 3,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                
                // Documents NOT Requiring Payment
                new DocumentType
                {
                    Name = "Diploma",
                    Description = "Official graduation diploma - No payment required",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 7,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new DocumentType
                {
                    Name = "Initial Form 138 (Report Card)",
                    Description = "Initial report card - No payment required",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new DocumentType
                {
                    Name = "Public School Form 137",
                    Description = "Public school permanent record - No payment required",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 5,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new DocumentType
                {
                    Name = "Informative Copy of Grades",
                    Description = "Informative copy of grades - No payment required",
                    ProcessingFee = 0.00m,
                    ProcessingDays = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                }
            };

            var addedCount = 0;
            var skippedCount = 0;

            foreach (var docType in documentTypes)
            {
                var exists = await _context.DocumentTypes
                    .AnyAsync(dt => dt.Name.ToLower() == docType.Name.ToLower());

                if (!exists)
                {
                    _context.DocumentTypes.Add(docType);
                    addedCount++;
                }
                else
                {
                    skippedCount++;
                }
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Document types seeding completed",
                added = addedCount,
                skipped = skippedCount,
                total = documentTypes.Count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error seeding document types");
            return StatusCode(500, new { message = "An error occurred while seeding document types", error = ex.Message });
        }
    }

    /// <summary>
    /// DELETE: api/Seed/document-types - Clear all document types (use with caution)
    /// </summary>
    [HttpDelete("document-types")]
    public async Task<IActionResult> ClearDocumentTypes()
    {
        try
        {
            var documentTypes = await _context.DocumentTypes.ToListAsync();
            var count = documentTypes.Count;
            
            _context.DocumentTypes.RemoveRange(documentTypes);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "All document types cleared",
                deleted = count
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error clearing document types");
            return StatusCode(500, new { message = "An error occurred while clearing document types", error = ex.Message });
        }
    }
}
