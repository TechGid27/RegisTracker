using System.ComponentModel.DataAnnotations;
using System.Linq;

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

    // Mobile sends "fee" — map to ProcessingFee
    public decimal? Fee { set { if (value.HasValue) ProcessingFee = value.Value; } }
    
    [Range(1, 30, ErrorMessage = "Processing days must be between 1 and 30")]
    public int ProcessingDays { get; set; } = 3;

    // Mobile sends "processingTime" as string e.g. "3 days" — parse it
    public string? ProcessingTime
    {
        set
        {
            if (!string.IsNullOrEmpty(value))
            {
                var digits = new string(value.Where(char.IsDigit).ToArray());
                if (int.TryParse(digits, out int days) && days >= 1 && days <= 30)
                    ProcessingDays = days;
            }
        }
    }
}

public class UpdateDocumentTypeDto
{
    [StringLength(100, MinimumLength = 3, ErrorMessage = "Name must be between 3 and 100 characters")]
    public string? Name { get; set; }
    
    [StringLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
    public string? Description { get; set; }
    
    [Range(0, 10000, ErrorMessage = "Processing fee must be between 0 and 10000")]
    public decimal? ProcessingFee { get; set; }

    public decimal? Fee { set { if (value.HasValue) ProcessingFee = value; } }
    
    [Range(1, 30, ErrorMessage = "Processing days must be between 1 and 30")]
    public int? ProcessingDays { get; set; }

    public string? ProcessingTime
    {
        set
        {
            if (!string.IsNullOrEmpty(value))
            {
                var digits = new string(value.Where(char.IsDigit).ToArray());
                if (int.TryParse(digits, out int days) && days >= 1 && days <= 30)
                    ProcessingDays = days;
            }
        }
    }
    
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

    // Aliases for mobile compatibility
    public decimal Fee => ProcessingFee;
    public string ProcessingTime => $"{ProcessingDays} day{(ProcessingDays == 1 ? "" : "s")}";
}
