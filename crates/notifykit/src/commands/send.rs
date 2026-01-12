use crate::cli::SendArgs;
use crate::notification::{InterruptionLevel, NotificationSound, send_notification};
use anyhow::Result;

pub fn run(args: SendArgs) -> Result<()> {
    let sound = match args.sound.as_deref() {
        None => NotificationSound::None,
        Some("default") => NotificationSound::Default,
        Some(name) => NotificationSound::Custom(name.to_string()),
    };

    let interruption_level = if args.banner {
        InterruptionLevel::Active
    } else {
        InterruptionLevel::TimeSensitive
    };

    send_notification(
        &args.title,
        args.subtitle.as_deref(),
        args.body.as_deref(),
        sound,
        interruption_level,
    )
}
