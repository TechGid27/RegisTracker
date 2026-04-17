using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Doctrack_backend_api.Data;
using Doctrack_backend_api.Models;
using Doctrack_backend_api.DTOs;
using Doctrack_backend_api.Services;

namespace Doctrack_backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly IEmailService _emailService;

    public AuthController(ApplicationDbContext context, IConfiguration configuration, IEmailService emailService)
    {
        _context = context;
        _configuration = configuration;
        _emailService = emailService;
    }

    [HttpPost("register")]
    public async Task<ActionResult> Register(RegisterDto dto)
    {
        if (await _context.Users.AnyAsync(u => u.Email == dto.Email))
            return BadRequest(new { message = "Email already exists" });

        if (await _context.Users.AnyAsync(u => u.StudentId == dto.StudentId))
            return BadRequest(new { message = "Student ID already exists" });

        var otp = GenerateOtp();

        var user = new User
        {
            FirstName = dto.FirstName,
            LastName = dto.LastName,
            Email = dto.Email,
            StudentId = dto.StudentId,
            PasswordHash = HashPassword(dto.Password),
            Role = "Student",
            IsActive = true,
            IsEmailVerified = false,
            OtpCode = otp,
            OtpExpiresAt = DateTime.UtcNow.AddMinutes(10),
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        _emailService.QueueOtpEmail(user.Email, $"{user.FirstName} {user.LastName}", otp);

        return Ok(new { message = "Registration successful. Please check your email for the OTP to verify your account." });
    }

    [HttpPost("verify-email")]
    public async Task<ActionResult<AuthResponseDto>> VerifyEmail(VerifyEmailDto dto)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);

        if (user == null)
            return BadRequest(new { message = "User not found" });

        if (user.IsEmailVerified)
            return BadRequest(new { message = "Email is already verified" });

        if (user.OtpCode != dto.Otp || user.OtpExpiresAt < DateTime.UtcNow)
            return BadRequest(new { message = "Invalid or expired OTP" });

        user.IsEmailVerified = true;
        user.OtpCode = null;
        user.OtpExpiresAt = null;
        await _context.SaveChangesAsync();

        var token = GenerateJwtToken(user);

        return Ok(new AuthResponseDto
        {
            Token = token,
            User = MapToUserResponse(user),
            ExpiresAt = DateTime.UtcNow.AddHours(24)
        });
    }

    [HttpPost("resend-otp")]
    public async Task<ActionResult> ResendOtp(ResendOtpDto dto)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);

        if (user == null)
            return BadRequest(new { message = "User not found" });

        if (user.IsEmailVerified)
            return BadRequest(new { message = "Email is already verified" });

        // Rate limit: dili pwede mag-resend if less than 1 minute ang nakalabay
        if (user.OtpExpiresAt.HasValue && user.OtpExpiresAt.Value > DateTime.UtcNow.AddMinutes(9))
            return BadRequest(new { message = "Please wait before requesting a new OTP" });

        var otp = GenerateOtp();
        user.OtpCode = otp;
        user.OtpExpiresAt = DateTime.UtcNow.AddMinutes(10);
        await _context.SaveChangesAsync();

        _emailService.QueueOtpEmail(user.Email, $"{user.FirstName} {user.LastName}", otp);

        return Ok(new { message = "A new OTP has been sent to your email." });
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login(LoginDto dto)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);

        if (user == null || !VerifyPassword(dto.Password, user.PasswordHash))
            return Unauthorized(new { message = "Invalid email or password" });

        if (!user.IsActive)
            return Unauthorized(new { message = "Account is inactive" });

        if (!user.IsEmailVerified)
            return Unauthorized(new { message = "Please verify your email before logging in", requiresVerification = true });

        var token = GenerateJwtToken(user);
        var expiresAt = DateTime.UtcNow.AddHours(24);

        return Ok(new AuthResponseDto
        {
            Token = token,
            User = MapToUserResponse(user),
            ExpiresAt = expiresAt
        });
    }

    private static string GenerateOtp() =>
        Random.Shared.Next(100000, 999999).ToString();

    private string HashPassword(string password) =>
        BCrypt.Net.BCrypt.HashPassword(password);

    private bool VerifyPassword(string password, string storedHash) =>
        BCrypt.Net.BCrypt.Verify(password, storedHash);

    private string GenerateJwtToken(User user)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
            _configuration["Jwt:Key"] ?? "YourSuperSecretKeyThatIsAtLeast32CharactersLong!"));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role),
            new Claim("StudentId", user.StudentId)
        };

        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"] ?? "DoctrackAPI",
            audience: _configuration["Jwt:Audience"] ?? "DoctrackClient",
            claims: claims,
            expires: DateTime.UtcNow.AddHours(24),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private UserResponseDto MapToUserResponse(User user)
    {
        return new UserResponseDto
        {
            Id = user.Id,
            FirstName = user.FirstName,
            LastName = user.LastName,
            Email = user.Email,
            StudentId = user.StudentId,
            Role = user.Role,
            IsActive = user.IsActive,
            CreatedAt = user.CreatedAt
        };
    }
}