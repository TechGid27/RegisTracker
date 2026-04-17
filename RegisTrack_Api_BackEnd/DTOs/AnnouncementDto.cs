using System.ComponentModel.DataAnnotations;

namespace Doctrack_backend_api.DTOs;

public class CreateAnnouncementDto
{
    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, MinimumLength = 5, ErrorMessage = "Title must be between 5 and 200 characters")]
    public string Title { get; set; } = string.Empty;
    
    [Required(ErrorMessage = "Content is required")]
    [StringLength(5000, MinimumLength = 10, ErrorMessage = "Content must be between 10 and 5000 characters")]
    public string Content { get; set; } = string.Empty;
    
    [Required(ErrorMessage = "Priority is required")]
    [RegularExpression("^(Low|Normal|High|Urgent)$", ErrorMessage = "Priority must be: Low, Normal, High, or Urgent")]
    public string Priority { get; set; } = "Normal";
    
    [Required(ErrorMessage = "Created by is required")]
    public int CreatedBy { get; set; }
    
    public DateTime? ExpiryDate { get; set; }
}

public class UpdateAnnouncementDto
{
    [StringLength(200, MinimumLength = 5, ErrorMessage = "Title must be between 5 and 200 characters")]
    public string? Title { get; set; }
    
    [StringLength(5000, MinimumLength = 10, ErrorMessage = "Content must be between 10 and 5000 characters")]
    public string? Content { get; set; }
    
    [RegularExpression("^(Low|Normal|High|Urgent)$", ErrorMessage = "Priority must be: Low, Normal, High, or Urgent")]
    public string? Priority { get; set; }
    
    public bool? IsActive { get; set; }
    
    public DateTime? ExpiryDate { get; set; }
}

public class AnnouncementResponseDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string Priority { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime PublishedDate { get; set; }
    public DateTime? ExpiryDate { get; set; }
    public int CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; }
}
