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
}

#[derive(clap::Args)]
pub struct CchookArgs {
    /// Play a sound with the notification (use "default" for system sound, or a custom sound name)
    #[arg(short, long)]
    pub sound: Option<String>,
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
    #[arg(short, long)]
    pub sound: Option<String>,
}
