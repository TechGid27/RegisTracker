using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Doctrack_backend_api.Data;
using Doctrack_backend_api.Models;
using Doctrack_backend_api.DTOs;

namespace Doctrack_backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DocumentTypesController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<DocumentTypesController> _logger;

    public DocumentTypesController(ApplicationDbContext context, ILogger<DocumentTypesController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// GET: api/DocumentTypes - Retrieve all document types
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<DocumentTypeResponseDto>>> GetDocumentTypes([FromQuery] bool? isActive = null)
    {
        try
        {
            var query = _context.DocumentTypes.AsQueryable();

            if (isActive.HasValue)
            {
                query = query.Where(dt => dt.IsActive == isActive.Value);
            }

            var documentTypes = await query
                .OrderBy(dt => dt.Name)
                .Select(dt => new DocumentTypeResponseDto
                {
                    Id = dt.Id,
                    Name = dt.Name,
                    Description = dt.Description,
                    ProcessingFee = dt.ProcessingFee,
                    ProcessingDays = dt.ProcessingDays,
                    IsActive = dt.IsActive,
                    CreatedAt = dt.CreatedAt
                })
                .ToListAsync();

            return Ok(documentTypes);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving document types");
            return StatusCode(500, new { message = "An error occurred while retrieving document types" });
        }
    }

    /// <summary>
    /// GET: api/DocumentTypes/{id} - Retrieve a specific document type
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<DocumentTypeResponseDto>> GetDocumentType(int id)
    {
        try
        {
            var documentType = await _context.DocumentTypes
                .Where(dt => dt.Id == id)
                .Select(dt => new DocumentTypeResponseDto
                {
                    Id = dt.Id,
                    Name = dt.Name,
                    Description = dt.Description,
                    ProcessingFee = dt.ProcessingFee,
                    ProcessingDays = dt.ProcessingDays,
                    IsActive = dt.IsActive,
                    CreatedAt = dt.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (documentType == null)
            {
                return NotFound(new { message = $"Document type with ID {id} not found" });
            }

            return Ok(documentType);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving document type {Id}", id);
            return StatusCode(500, new { message = "An error occurred while retrieving the document type" });
        }
    }

    /// <summary>
    /// POST: api/DocumentTypes - Create a new document type (Admin only)
    /// </summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<DocumentTypeResponseDto>> CreateDocumentType(CreateDocumentTypeDto dto)
    {
        try
        {
            // Check for duplicate name
            var exists = await _context.DocumentTypes.AnyAsync(dt => dt.Name.ToLower() == dto.Name.ToLower());
            if (exists)
            {
                return BadRequest(new { message = "A document type with this name already exists" });
            }

            var documentType = new DocumentType
            {
                Name = dto.Name,
                Description = dto.Description ?? string.Empty,
                ProcessingFee = dto.ProcessingFee,
                ProcessingDays = dto.ProcessingDays,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.DocumentTypes.Add(documentType);
            await _context.SaveChangesAsync();

            var response = new DocumentTypeResponseDto
            {
                Id = documentType.Id,
                Name = documentType.Name,
                Description = documentType.Description,
                ProcessingFee = documentType.ProcessingFee,
                ProcessingDays = documentType.ProcessingDays,
                IsActive = documentType.IsActive,
                CreatedAt = documentType.CreatedAt
            };

            return CreatedAtAction(nameof(GetDocumentType), new { id = documentType.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating document type");
            return StatusCode(500, new { message = "An error occurred while creating the document type" });
        }
    }

    /// <summary>
    /// PUT: api/DocumentTypes/{id} - Update a document type (Admin only)
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateDocumentType(int id, UpdateDocumentTypeDto dto)
    {
        try
        {
            var documentType = await _context.DocumentTypes.FindAsync(id);
            if (documentType == null)
            {
                return NotFound(new { message = $"Document type with ID {id} not found" });
            }

            // Check for duplicate name if name is being updated
            if (!string.IsNullOrEmpty(dto.Name) && dto.Name != documentType.Name)
            {
                var exists = await _context.DocumentTypes.AnyAsync(dt => dt.Name.ToLower() == dto.Name.ToLower() && dt.Id != id);
                if (exists)
                {
                    return BadRequest(new { message = "A document type with this name already exists" });
                }
                documentType.Name = dto.Name;
            }

            if (dto.Description != null)
            {
                documentType.Description = dto.Description;
            }

            if (dto.ProcessingFee.HasValue)
            {
                documentType.ProcessingFee = dto.ProcessingFee.Value;
            }

            if (dto.ProcessingDays.HasValue)
            {
                documentType.ProcessingDays = dto.ProcessingDays.Value;
            }

            if (dto.IsActive.HasValue)
            {
                documentType.IsActive = dto.IsActive.Value;
            }

            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating document type {Id}", id);
            return StatusCode(500, new { message = "An error occurred while updating the document type" });
        }
    }

    /// <summary>
    /// DELETE: api/DocumentTypes/{id} - Delete a document type (Admin only)
    /// </summary>
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteDocumentType(int id)
    {
        try
        {
            var documentType = await _context.DocumentTypes.FindAsync(id);
            if (documentType == null)
            {
                return NotFound(new { message = $"Document type with ID {id} not found" });
            }

            // Check if document type is being used
            var hasRequests = await _context.DocumentRequests.AnyAsync(dr => dr.DocumentTypeId == id);
            if (hasRequests)
            {
                return BadRequest(new { message = "Cannot delete document type that has associated requests. Consider deactivating instead." });
            }

            _context.DocumentTypes.Remove(documentType);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting document type {Id}", id);
            return StatusCode(500, new { message = "An error occurred while deleting the document type" });
        }
    }
}
