using System.ComponentModel.DataAnnotations;

namespace Doctrack_backend_api.DTOs;

public class CreateDocumentRequestDto
{
    [Required(ErrorMessage = "User ID is required")]
    public int UserId { get; set; }
    
    [Required(ErrorMessage = "Document Type ID is required")]
    public int DocumentTypeId { get; set; }
    
    [Required(ErrorMessage = "Purpose is required")]
    [StringLength(1000, MinimumLength = 10, ErrorMessage = "Purpose must be between 10 and 1000 characters")]
    public string Purpose { get; set; } = string.Empty;
    
    [Range(1, 100, ErrorMessage = "Quantity must be between 1 and 100")]
    public int Quantity { get; set; } = 1;
    
    [StringLength(2000, ErrorMessage = "Notes cannot exceed 2000 characters")]
    public string? Notes { get; set; }
}

public class UpdateDocumentRequestDto
{
    [Required(ErrorMessage = "Status is required")]
    [RegularExpression("^(Request|InProcess|Approve|Receive|Download)$", 
        ErrorMessage = "Status must be: Request, InProcess, Approve, Receive, or Download")]
    public string Status { get; set; } = string.Empty;
    
    [StringLength(2000, ErrorMessage = "Notes cannot exceed 2000 characters")]
    public string? Notes { get; set; }
    
    [StringLength(500, ErrorMessage = "Document URL cannot exceed 500 characters")]
    public string? DocumentUrl { get; set; }
    
    public int? ProcessedBy { get; set; }
    
    public int? ApprovedBy { get; set; }
}

public class DocumentRequestResponseDto
{
    public int Id { get; set; }
    public string ReferenceNumber { get; set; } = string.Empty;
    public int UserId { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string UserEmail { get; set; } = string.Empty;
    public int DocumentTypeId { get; set; }
    public string DocumentTypeName { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public string Purpose { get; set; } = string.Empty;
    public string Notes { get; set; } = string.Empty;
    public DateTime RequestDate { get; set; }
    public DateTime? ProcessedDate { get; set; }
    public DateTime? ApprovedDate { get; set; }
    public DateTime? CompletedDate { get; set; }
    public string DocumentUrl { get; set; } = string.Empty;
    public bool EmailSent { get; set; }
}
