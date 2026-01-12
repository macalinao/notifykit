use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(
    name = "notifykit",
    about = "macOS notification CLI with Claude Code hook support",
    version
)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Send a macOS notification
    Send(SendArgs),
    /// Claude Code hook that reads from stdin and sends notifications
    Cchook(CchookArgs),
    /// List available notification sounds
    Sounds,
    /// Send a test notification
    SendTestNotification,
}

#[derive(clap::Args)]
pub struct CchookArgs {
    /// Play a sound with the notification (use "default" for system sound, or a custom sound name)
    #[arg(short, long, default_missing_value = "default", num_args = 0..=1)]
    pub sound: Option<String>,

    /// Use banner style instead of alert (banners auto-dismiss after a few seconds)
    #[arg(long)]
    pub banner: bool,

    /// Debug mode: show raw stdin input in notification instead of formatted message
    #[arg(long)]
    pub raw: bool,
}

#[derive(clap::Args)]
pub struct SendArgs {
    /// Notification title
    #[arg(short, long)]
    pub title: String,

    /// Notification body (optional)
    #[arg(short, long)]
    pub body: Option<String>,

    /// Notification subtitle (optional)
    #[arg(long)]
    pub subtitle: Option<String>,

    /// Play a sound with the notification (use "default" for system sound, or a custom sound name)
    #[arg(short, long, default_missing_value = "default", num_args = 0..=1)]
    pub sound: Option<String>,

    /// Use banner style instead of alert (banners auto-dismiss after a few seconds)
    #[arg(long)]
    pub banner: bool,

    /// Group notifications with the same thread identifier together
    #[arg(long)]
    pub thread: Option<String>,
}
