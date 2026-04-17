using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Doctrack_backend_api.Data;
using Doctrack_backend_api.Models;
using Doctrack_backend_api.DTOs;

namespace Doctrack_backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AnnouncementsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<AnnouncementsController> _logger;

    public AnnouncementsController(ApplicationDbContext context, ILogger<AnnouncementsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    /// <summary>
    /// GET: api/Announcements - Retrieve all announcements
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<IEnumerable<AnnouncementResponseDto>>> GetAnnouncements(
        [FromQuery] bool? isActive = null,
        [FromQuery] string? priority = null)
    {
        try
        {
            var query = _context.Announcements.AsQueryable();

            if (isActive.HasValue)
            {
                query = query.Where(a => a.IsActive == isActive.Value);
            }

            if (!string.IsNullOrEmpty(priority))
            {
                query = query.Where(a => a.Priority == priority);
            }

            // Filter out expired announcements
            var now = DateTime.UtcNow;
            query = query.Where(a => a.ExpiryDate == null || a.ExpiryDate > now);

            var announcements = await query
                .OrderByDescending(a => a.Priority == "Urgent")
                .ThenByDescending(a => a.Priority == "High")
                .ThenByDescending(a => a.PublishedDate)
                .Select(a => new AnnouncementResponseDto
                {
                    Id = a.Id,
                    Title = a.Title,
                    Content = a.Content,
                    Priority = a.Priority,
                    IsActive = a.IsActive,
                    PublishedDate = a.PublishedDate,
                    ExpiryDate = a.ExpiryDate,
                    CreatedBy = a.CreatedBy,
                    CreatedAt = a.CreatedAt
                })
                .ToListAsync();

            return Ok(announcements);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving announcements");
            return StatusCode(500, new { message = "An error occurred while retrieving announcements" });
        }
    }

    /// <summary>
    /// GET: api/Announcements/{id} - Retrieve a specific announcement
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<AnnouncementResponseDto>> GetAnnouncement(int id)
    {
        try
        {
            var announcement = await _context.Announcements
                .Where(a => a.Id == id)
                .Select(a => new AnnouncementResponseDto
                {
                    Id = a.Id,
                    Title = a.Title,
                    Content = a.Content,
                    Priority = a.Priority,
                    IsActive = a.IsActive,
                    PublishedDate = a.PublishedDate,
                    ExpiryDate = a.ExpiryDate,
                    CreatedBy = a.CreatedBy,
                    CreatedAt = a.CreatedAt
                })
                .FirstOrDefaultAsync();

            if (announcement == null)
            {
                return NotFound(new { message = $"Announcement with ID {id} not found" });
            }

            return Ok(announcement);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving announcement {Id}", id);
            return StatusCode(500, new { message = "An error occurred while retrieving the announcement" });
        }
    }

    /// <summary>
    /// POST: api/Announcements - Create a new announcement (Admin only)
    /// </summary>
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<AnnouncementResponseDto>> CreateAnnouncement(CreateAnnouncementDto dto)
    {
        try
        {
            // Validate creator exists
            var creatorExists = await _context.Users.AnyAsync(u => u.Id == dto.CreatedBy && u.IsActive);
            if (!creatorExists)
            {
                return BadRequest(new { message = "Invalid or inactive creator user" });
            }

            // Validate expiry date
            if (dto.ExpiryDate.HasValue && dto.ExpiryDate.Value <= DateTime.UtcNow)
            {
                return BadRequest(new { message = "Expiry date must be in the future" });
            }

            var announcement = new Announcement
            {
                Title = dto.Title,
                Content = dto.Content,
                Priority = dto.Priority,
                IsActive = true,
                PublishedDate = DateTime.UtcNow,
                ExpiryDate = dto.ExpiryDate,
                CreatedBy = dto.CreatedBy,
                CreatedAt = DateTime.UtcNow
            };

            _context.Announcements.Add(announcement);
            await _context.SaveChangesAsync();

            var response = new AnnouncementResponseDto
            {
                Id = announcement.Id,
                Title = announcement.Title,
                Content = announcement.Content,
                Priority = announcement.Priority,
                IsActive = announcement.IsActive,
                PublishedDate = announcement.PublishedDate,
                ExpiryDate = announcement.ExpiryDate,
                CreatedBy = announcement.CreatedBy,
                CreatedAt = announcement.CreatedAt
            };

            return CreatedAtAction(nameof(GetAnnouncement), new { id = announcement.Id }, response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating announcement");
            return StatusCode(500, new { message = "An error occurred while creating the announcement" });
        }
    }

    /// <summary>
    /// PUT: api/Announcements/{id} - Update an announcement (Admin only)
    /// </summary>
    [HttpPut("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateAnnouncement(int id, UpdateAnnouncementDto dto)
    {
        try
        {
            var announcement = await _context.Announcements.FindAsync(id);
            if (announcement == null)
            {
                return NotFound(new { message = $"Announcement with ID {id} not found" });
            }

            if (!string.IsNullOrEmpty(dto.Title))
            {
                announcement.Title = dto.Title;
            }

            if (!string.IsNullOrEmpty(dto.Content))
            {
                announcement.Content = dto.Content;
            }

            if (!string.IsNullOrEmpty(dto.Priority))
            {
                announcement.Priority = dto.Priority;
            }

            if (dto.IsActive.HasValue)
            {
                announcement.IsActive = dto.IsActive.Value;
            }

            if (dto.ExpiryDate.HasValue)
            {
                if (dto.ExpiryDate.Value <= DateTime.UtcNow)
                {
                    return BadRequest(new { message = "Expiry date must be in the future" });
                }
                announcement.ExpiryDate = dto.ExpiryDate.Value;
            }

            announcement.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating announcement {Id}", id);
            return StatusCode(500, new { message = "An error occurred while updating the announcement" });
        }
    }

    /// <summary>
    /// DELETE: api/Announcements/{id} - Delete an announcement (Admin only)
    /// </summary>
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteAnnouncement(int id)
    {
        try
        {
            var announcement = await _context.Announcements.FindAsync(id);
            if (announcement == null)
            {
                return NotFound(new { message = $"Announcement with ID {id} not found" });
            }

            _context.Announcements.Remove(announcement);
            await _context.SaveChangesAsync();

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting announcement {Id}", id);
            return StatusCode(500, new { message = "An error occurred while deleting the announcement" });
        }
    }
}
