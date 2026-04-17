using System.ComponentModel.DataAnnotations;

namespace Doctrack_backend_api.Models;

public class DocumentRequest
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(50)]
    public string ReferenceNumber { get; set; } = string.Empty;
    
    [Required]
    public int UserId { get; set; }
    
    [Required]
    public int DocumentTypeId { get; set; }
    
    [Required]
    [StringLength(20)]
    public string Status { get; set; } = "Request"; // Request, InProcess, Approve, Receive, Download
    
    [Range(1, 100)]
    public int Quantity { get; set; } = 1;
    
    [StringLength(1000)]
    public string Purpose { get; set; } = string.Empty;
    
    [StringLength(2000)]
    public string Notes { get; set; } = string.Empty;
    
    public DateTime RequestDate { get; set; } = DateTime.UtcNow;
    
    public DateTime? ProcessedDate { get; set; }
    
    public DateTime? ApprovedDate { get; set; }
    
    public DateTime? CompletedDate { get; set; }
    
    public int? ProcessedBy { get; set; }
    
    public int? ApprovedBy { get; set; }
    
    [StringLength(500)]
    public string DocumentUrl { get; set; } = string.Empty;
    
    public bool EmailSent { get; set; } = false;
    
    public DateTime? LastEmailSentAt { get; set; }
    
    // Navigation properties
    public User User { get; set; } = null!;
    public DocumentType DocumentType { get; set; } = null!;
}
