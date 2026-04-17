using System.Threading.Channels;

namespace Doctrack_backend_api.Services;

public record EmailMessage(
    string ToEmail,
    string ToName,
    string Subject,
    string HtmlBody,
    string? AttachmentPath = null
);

public interface IEmailQueue
{
    void Enqueue(EmailMessage message);
    IAsyncEnumerable<EmailMessage> DequeueAllAsync(CancellationToken ct);
}

public class EmailQueue : IEmailQueue
{
    // bounded capacity = max 100 emails in queue, drops oldest if full
    private readonly Channel<EmailMessage> _channel = Channel.CreateBounded<EmailMessage>(
        new BoundedChannelOptions(100)
        {
            FullMode = BoundedChannelFullMode.DropOldest,
            SingleReader = true
        });

    public void Enqueue(EmailMessage message) =>
        _channel.Writer.TryWrite(message);

    public async IAsyncEnumerable<EmailMessage> DequeueAllAsync([System.Runtime.CompilerServices.EnumeratorCancellation] CancellationToken ct)
    {
        await foreach (var msg in _channel.Reader.ReadAllAsync(ct))
            yield return msg;
    }
}
