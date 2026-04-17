using System.ComponentModel.DataAnnotations;

namespace Doctrack_backend_api.Models;

public class DocumentType
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [StringLength(500)]
    public string Description { get; set; } = string.Empty;
    
    [Range(0, 10000)]
    public decimal ProcessingFee { get; set; }
    
    [Range(1, 30)]
    public int ProcessingDays { get; set; } = 3;
    
    public bool IsActive { get; set; } = true;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public ICollection<DocumentRequest> DocumentRequests { get; set; } = new List<DocumentRequest>();
    public ICollection<DocumentRequirement> Requirements { get; set; } = new List<DocumentRequirement>();
}
