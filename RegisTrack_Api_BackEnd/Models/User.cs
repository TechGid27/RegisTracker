using System.ComponentModel.DataAnnotations;

namespace Doctrack_backend_api.Models;

public class User
{
    public int Id { get; set; }
    
    [Required]
    [StringLength(100)]
    public string FirstName { get; set; } = string.Empty;
    
    [Required]
    [StringLength(100)]
    public string LastName { get; set; } = string.Empty;
    
    [Required]
    [EmailAddress]
    [StringLength(255)]
    public string Email { get; set; } = string.Empty;
    
    [Required]
    [StringLength(50)]
    public string StudentId { get; set; } = string.Empty;
    
    [Required]
    [StringLength(20)]
    public string Role { get; set; } = "Student"; // Student, Admin
    
    [Required]
    [StringLength(255)]
    public string PasswordHash { get; set; } = string.Empty;
    
    public bool IsActive { get; set; } = true;

    public bool IsEmailVerified { get; set; } = false;

    public string? OtpCode { get; set; }

    public DateTime? OtpExpiresAt { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation property
    public ICollection<DocumentRequest> DocumentRequests { get; set; } = new List<DocumentRequest>();
}
