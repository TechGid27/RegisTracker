namespace Doctrack_backend_api.Services;

public class EmailWorker : BackgroundService
{
    private readonly IEmailQueue _queue;
    private readonly IEmailSender _sender;
    private readonly ILogger<EmailWorker> _logger;

    public EmailWorker(IEmailQueue queue, IEmailSender sender, ILogger<EmailWorker> logger)
    {
        _queue = queue;
        _sender = sender;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Email worker started.");
        await foreach (var msg in _queue.DequeueAllAsync(stoppingToken))
        {
            try
            {
                await _sender.SendAsync(msg);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email to {Email}", msg.ToEmail);
            }
        }
    }
}
