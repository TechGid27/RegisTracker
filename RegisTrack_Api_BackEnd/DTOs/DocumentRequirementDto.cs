using System.ComponentModel.DataAnnotations;

namespace Doctrack_backend_api.DTOs;

public class CreateDocumentRequirementDto
{
    [Required(ErrorMessage = "Document Type ID is required")]
    public int DocumentTypeId { get; set; }
    
    [Required(ErrorMessage = "Requirement name is required")]
    [StringLength(200, MinimumLength = 3, ErrorMessage = "Requirement name must be between 3 and 200 characters")]
    public string RequirementName { get; set; } = string.Empty;
    
    [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
    public string? Description { get; set; }
    
    public bool IsMandatory { get; set; } = true;
    
    [Range(0, 1000, ErrorMessage = "Display order must be between 0 and 1000")]
    public int DisplayOrder { get; set; } = 0;
}

public class UpdateDocumentRequirementDto
{
    [StringLength(200, MinimumLength = 3, ErrorMessage = "Requirement name must be between 3 and 200 characters")]
    public string? RequirementName { get; set; }
    
    [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
    public string? Description { get; set; }
    
    public bool? IsMandatory { get; set; }
    
    [Range(0, 1000, ErrorMessage = "Display order must be between 0 and 1000")]
    public int? DisplayOrder { get; set; }
}

public class DocumentRequirementResponseDto
{
    public int Id { get; set; }
    public int DocumentTypeId { get; set; }
    public string DocumentTypeName { get; set; } = string.Empty;
    public string RequirementName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public bool IsMandatory { get; set; }
    public int DisplayOrder { get; set; }
    public DateTime CreatedAt { get; set; }
}
