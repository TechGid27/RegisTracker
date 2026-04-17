using System.Net;
using System.Net.Mail;

namespace Doctrack_backend_api.Services;

// Handles actual SMTP sending
public interface IEmailSender
{
    Task SendAsync(EmailMessage message);
}

public class SmtpEmailSender : IEmailSender
{
    private readonly IConfiguration _config;
    private readonly ILogger<SmtpEmailSender> _logger;

    public SmtpEmailSender(IConfiguration config, ILogger<SmtpEmailSender> logger)
    {
        _config = config;
        _logger = logger;
    }

    public async Task SendAsync(EmailMessage message)
    {
        var host = _config["Email:SmtpHost"]!;
        var port = int.Parse(_config["Email:SmtpPort"]!);
        var username = _config["Email:Username"]!;
        var password = _config["Email:Password"]!;
        var fromEmail = _config["Email:FromEmail"]!;
        var fromName = _config["Email:FromName"]!;

        using var client = new SmtpClient(host, port)
        {
            Credentials = new NetworkCredential(username, password),
            EnableSsl = true
        };

        var mail = new MailMessage
        {
            From = new MailAddress(fromEmail, fromName),
            Subject = message.Subject,
            Body = message.HtmlBody,
            IsBodyHtml = true
        };
        mail.To.Add(new MailAddress(message.ToEmail, message.ToName));

        if (!string.IsNullOrEmpty(message.AttachmentPath) && System.IO.File.Exists(message.AttachmentPath))
        {
            mail.Attachments.Add(new Attachment(message.AttachmentPath));
        }

        await client.SendMailAsync(mail);
        _logger.LogInformation("Email sent to {Email} - {Subject}", message.ToEmail, message.Subject);
    }
}

// Builds email content and enqueues — never blocks the request
public interface IEmailService
{
    void QueueStatusUpdateEmail(string toEmail, string toName, string referenceNumber, string status, string? notes = null, string? attachmentPath = null);
    void QueueRequestConfirmationEmail(string toEmail, string toName, string referenceNumber, string documentType);
    void QueueOtpEmail(string toEmail, string toName, string otp);
}

public class EmailService : IEmailService
{
    private readonly IEmailQueue _queue;

    public EmailService(IEmailQueue queue) => _queue = queue;

    public void QueueStatusUpdateEmail(string toEmail, string toName, string referenceNumber, string status, string? notes = null, string? attachmentPath = null)
    {
        var statusMessage = status switch
        {
            "InProcess" => "Your document request is now being processed.",
            "Approve"   => "Your document request has been approved.",
            "Receive"   => "Your document is ready for pickup.",
            "Download"  => "Your document is now available for download.",
            _           => $"Your document request status has been updated to: {status}."
        };

        var body = $@"
<html><body style='font-family:Arial,sans-serif;color:#333;'>
  <h2>Document Request Status Update</h2>
  <p>Hello <strong>{toName}</strong>,</p>
  <p>{statusMessage}</p>
  <table style='border-collapse:collapse;margin:16px 0;'>
    <tr><td style='padding:6px 12px;font-weight:bold;'>Reference Number:</td><td style='padding:6px 12px;'>{referenceNumber}</td></tr>
    <tr><td style='padding:6px 12px;font-weight:bold;'>Status:</td><td style='padding:6px 12px;'>{status}</td></tr>
    {(string.IsNullOrEmpty(notes) ? "" : $"<tr><td style='padding:6px 12px;font-weight:bold;'>Notes:</td><td style='padding:6px 12px;'>{notes}</td></tr>")}
  </table>
  <p style='color:#888;font-size:12px;'>This is an automated message from DocTrack System.</p>
</body></html>";

        _queue.Enqueue(new EmailMessage(toEmail, toName, $"Document Request Update - {referenceNumber}", body, attachmentPath));
    }

    public void QueueRequestConfirmationEmail(string toEmail, string toName, string referenceNumber, string documentType)
    {
        var body = $@"
<html><body style='font-family:Arial,sans-serif;color:#333;'>
  <h2>Document Request Confirmation</h2>
  <p>Hello <strong>{toName}</strong>,</p>
  <p>Your document request has been successfully submitted.</p>
  <table style='border-collapse:collapse;margin:16px 0;'>
    <tr><td style='padding:6px 12px;font-weight:bold;'>Reference Number:</td><td style='padding:6px 12px;'>{referenceNumber}</td></tr>
    <tr><td style='padding:6px 12px;font-weight:bold;'>Document Type:</td><td style='padding:6px 12px;'>{documentType}</td></tr>
    <tr><td style='padding:6px 12px;font-weight:bold;'>Status:</td><td style='padding:6px 12px;'>Request</td></tr>
  </table>
  <p>Please keep your reference number for tracking purposes.</p>
  <p style='color:#888;font-size:12px;'>This is an automated message from DocTrack System.</p>
</body></html>";

        _queue.Enqueue(new EmailMessage(toEmail, toName, $"Document Request Received - {referenceNumber}", body));
    }

    public void QueueOtpEmail(string toEmail, string toName, string otp)
    {
        var body = $@"
<html><body style='font-family:Arial,sans-serif;color:#333;'>
  <h2>Verify Your Email</h2>
  <p>Hello <strong>{toName}</strong>,</p>
  <p>Use the OTP below to verify your email address. It expires in <strong>10 minutes</strong>.</p>
  <div style='font-size:32px;font-weight:bold;letter-spacing:8px;margin:24px 0;color:#4F46E5;'>{otp}</div>
  <p>If you did not register, ignore this email.</p>
  <p style='color:#888;font-size:12px;'>This is an automated message from DocTrack System.</p>
</body></html>";

        _queue.Enqueue(new EmailMessage(toEmail, toName, "DocTrack - Email Verification OTP", body));
    }
}
