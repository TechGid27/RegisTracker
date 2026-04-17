using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Doctrack_backend_api.Data;
using Doctrack_backend_api.Models;
using Doctrack_backend_api.DTOs;

namespace Doctrack_backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DocumentRequirementsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<DocumentRequirementsController> _logger;

    public DocumentRequirementsController(ApplicationDbContext context, ILogger<DocumentRequirementsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// GET: api/DocumentRequirements - Retrieve all document requirements
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<DocumentRequirementResponseDto>>> GetDocumentRequirements(
        [FromQuery] int? documentTypeId = null)
    {
        try
        {
            var query = _context.DocumentRequirements
                .Include(dr => dr.DocumentType)
                .AsQueryable();

            if (documentTypeId.HasValue)
            {
                query = query.Where(dr => dr.DocumentTypeId == documentTypeId.Value);
            }

            var requirements = await query
                .OrderBy(dr => dr.DocumentTypeId)
                .ThenBy(dr => dr.DisplayOrder)
                .Select(dr => new DocumentRequirementResponseDto
                {
                    Id = dr.Id,
                    DocumentTypeId = dr.DocumentTypeId,
                    DocumentTypeName = dr.DocumentType.Name,
                    RequirementName = dr.RequirementName,
                    Description = dr.Description,
                    IsMandatory = dr.IsMandatory,
                    DisplayOrder = dr.DisplayOrder,
                    CreatedAt = dr.CreatedAt
                })
                .ToListAsync();

            return Ok(requirements);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving document requirements");
            return StatusCode(500, new { message = "An error occurred while retrieving document requirements" });
        }
    }

    /// <summary>
    /// GET: api/DocumentRequirements/{id} - Retrieve a specific document requirement
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<DocumentRequirementResponseDto>> GetDocumentRequirement(int id)
    {
        try
        {
            var requirement = await _context.DocumentRequirements
                .Include(dr => dr.DocumentType)
                .Where(dr => dr.Id == id)
                .Select(dr => new DocumentRequirementResponseDto
                {
                    Id = dr.Id,
                    DocumentTypeId = dr.DocumentTypeId,
                    DocumentTypeName = dr.DocumentType.Name,
                    RequirementName = dr.RequirementName,
                    Description = dr.Description,
                    IsMandatory = dr.IsMandatory,
                    DisplayOrder = dr.DisplayOrder,
                    CreatedAt = dr.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (requirement == null)
            {
                return NotFound(new { message = $"Document requirement with ID {id} not found" });
            }

            return Ok(requirement);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving document requirement {Id}", id);
            return StatusCode(500, new { message = "An error occurred while retrieving the document requirement" });
        }
    }

    /// <summary>
    /// POST: api/DocumentRequirements - Create a new document requirement (Admin only)
    /// </summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<DocumentRequirementResponseDto>> CreateDocumentRequirement(CreateDocumentRequirementDto dto)
    {
        try
        {
            // Validate document type exists
            var documentTypeExists = await _context.DocumentTypes.AnyAsync(dt => dt.Id == dto.DocumentTypeId);
            if (!documentTypeExists)
            {
                return BadRequest(new { message = "Invalid document type" });
            }

            var requirement = new DocumentRequirement
            {
                DocumentTypeId = dto.DocumentTypeId,
                RequirementName = dto.RequirementName,
                Description = dto.Description ?? string.Empty,
                IsMandatory = dto.IsMandatory,
                DisplayOrder = dto.DisplayOrder,
                CreatedAt = DateTime.UtcNow
            };

            _context.DocumentRequirements.Add(requirement);
            await _context.SaveChangesAsync();

            var createdRequirement = await _context.DocumentRequirements
                .Include(dr => dr.DocumentType)
                .Where(dr => dr.Id == requirement.Id)
                .Select(dr => new DocumentRequirementResponseDto
                {
                    Id = dr.Id,
                    DocumentTypeId = dr.DocumentTypeId,
                    DocumentTypeName = dr.DocumentType.Name,
                    RequirementName = dr.RequirementName,
                    Description = dr.Description,
                    IsMandatory = dr.IsMandatory,
                    DisplayOrder = dr.DisplayOrder,
                    CreatedAt = dr.CreatedAt
                })
                .FirstAsync();

            return CreatedAtAction(nameof(GetDocumentRequirement), new { id = requirement.Id }, createdRequirement);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating document requirement");
            return StatusCode(500, new { message = "An error occurred while creating the document requirement" });
        }
    }

    /// <summary>
    /// PUT: api/DocumentRequirements/{id} - Update a document requirement (Admin only)
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateDocumentRequirement(int id, UpdateDocumentRequirementDto dto)
    {
        try
        {
            var requirement = await _context.DocumentRequirements.FindAsync(id);
            if (requirement == null)
            {
                return NotFound(new { message = $"Document requirement with ID {id} not found" });
            }

            if (!string.IsNullOrEmpty(dto.RequirementName))
            {
                requirement.RequirementName = dto.RequirementName;
            }

            if (dto.Description != null)
            {
                requirement.Description = dto.Description;
            }

            if (dto.IsMandatory.HasValue)
            {
                requirement.IsMandatory = dto.IsMandatory.Value;
            }

            if (dto.DisplayOrder.HasValue)
            {
                requirement.DisplayOrder = dto.DisplayOrder.Value;
            }

            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating document requirement {Id}", id);
            return StatusCode(500, new { message = "An error occurred while updating the document requirement" });
        }
    }

    /// <summary>
    /// DELETE: api/DocumentRequirements/{id} - Delete a document requirement (Admin only)
    /// </summary>
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteDocumentRequirement(int id)
    {
        try
        {
            var requirement = await _context.DocumentRequirements.FindAsync(id);
            if (requirement == null)
            {
                return NotFound(new { message = $"Document requirement with ID {id} not found" });
            }

            _context.DocumentRequirements.Remove(requirement);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting document requirement {Id}", id);
            return StatusCode(500, new { message = "An error occurred while deleting the document requirement" });
        }
    }
}
