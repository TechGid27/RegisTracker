using System.ComponentModel.DataAnnotations;

namespace Doctrack_backend_api.Models;

public class Announcement
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(200)]
    public string Title { get; set; } = string.Empty;
    
    [Required]
    [StringLength(5000)]
    public string Content { get; set; } = string.Empty;
    
    [Required]
    [StringLength(20)]
    public string Priority { get; set; } = "Normal"; // Low, Normal, High, Urgent
    
    public bool IsActive { get; set; } = true;
    
    public DateTime PublishedDate { get; set; } = DateTime.UtcNow;
    
    public DateTime? ExpiryDate { get; set; }
    
    public int CreatedBy { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
}
