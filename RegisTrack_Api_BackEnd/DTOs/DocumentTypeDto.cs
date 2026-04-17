using System.ComponentModel.DataAnnotations;

namespace Doctrack_backend_api.DTOs;

public class CreateDocumentTypeDto
{
    [Required(ErrorMessage = "Document name is required")]
    [StringLength(100, MinimumLength = 3, ErrorMessage = "Name must be between 3 and 100 characters")]
    public string Name { get; set; } = string.Empty;
    
    [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
    public string? Description { get; set; }
    
    [Range(0, 10000, ErrorMessage = "Processing fee must be between 0 and 10000")]
    public decimal ProcessingFee { get; set; } = 0;
    
    [Range(1, 30, ErrorMessage = "Processing days must be between 1 and 30")]
    public int ProcessingDays { get; set; } = 3;
}

public class UpdateDocumentTypeDto
{
    [StringLength(100, MinimumLength = 3, ErrorMessage = "Name must be between 3 and 100 characters")]
    public string? Name { get; set; }
    
    [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
    public string? Description { get; set; }
    
    [Range(0, 10000, ErrorMessage = "Processing fee must be between 0 and 10000")]
    public decimal? ProcessingFee { get; set; }
    
    [Range(1, 30, ErrorMessage = "Processing days must be between 1 and 30")]
    public int? ProcessingDays { get; set; }
    
    public bool? IsActive { get; set; }
}

public class DocumentTypeResponseDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal ProcessingFee { get; set; }
    public int ProcessingDays { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}
