using Microsoft.EntityFrameworkCore;
using Doctrack_backend_api.Models;

namespace Doctrack_backend_api.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }
    
    public DbSet<User> Users { get; set; }
    public DbSet<DocumentType> DocumentTypes { get; set; }
    public DbSet<DocumentRequest> DocumentRequests { get; set; }
    public DbSet<DocumentRequirement> DocumentRequirements { get; set; }
    public DbSet<Announcement> Announcements { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // User configuration
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();
            
        modelBuilder.Entity<User>()
            .HasIndex(u => u.StudentId)
            .IsUnique();
        
        // DocumentRequest configuration
        modelBuilder.Entity<DocumentRequest>()
            .HasIndex(dr => dr.ReferenceNumber)
            .IsUnique();
            
        modelBuilder.Entity<DocumentRequest>()
            .HasOne(dr => dr.User)
            .WithMany(u => u.DocumentRequests)
            .HasForeignKey(dr => dr.UserId)
            .OnDelete(DeleteBehavior.Restrict);
            
        modelBuilder.Entity<DocumentRequest>()
            .HasOne(dr => dr.DocumentType)
            .WithMany(dt => dt.DocumentRequests)
            .HasForeignKey(dr => dr.DocumentTypeId)
            .OnDelete(DeleteBehavior.Restrict);
        
        // DocumentRequirement configuration
        modelBuilder.Entity<DocumentRequirement>()
            .HasOne(dr => dr.DocumentType)
            .WithMany(dt => dt.Requirements)
            .HasForeignKey(dr => dr.DocumentTypeId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
