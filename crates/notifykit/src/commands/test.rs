use crate::notification::{InterruptionLevel, NotificationSound, send_notification};
use anyhow::Result;

pub fn run() -> Result<()> {
    send_notification(
        "NotifyKit",
        None,
        Some("Test notification - NotifyKit is working!"),
        NotificationSound::Default,
        InterruptionLevel::TimeSensitive,
    )
}
