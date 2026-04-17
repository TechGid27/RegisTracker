using System.ComponentModel.DataAnnotations;

namespace Doctrack_backend_api.Models;

public class DocumentRequirement
{
    public int Id { get; set; }
    
    [Required]
    public int DocumentTypeId { get; set; }
    
    [Required]
    [StringLength(200)]
    public string RequirementName { get; set; } = string.Empty;
    
    [StringLength(500)]
    public string Description { get; set; } = string.Empty;
    
    public bool IsMandatory { get; set; } = true;
    
    public int DisplayOrder { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation property
    public DocumentType DocumentType { get; set; } = null!;
}
