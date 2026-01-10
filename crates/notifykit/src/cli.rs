use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "notifykit")]
#[command(about = "macOS notification CLI with Claude Code hook support")]
#[command(version)]
pub struct Cli {
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Send a macOS notification
    Send(SendArgs),
    /// Claude Code hook that reads from stdin and sends notifications
    Cchook,
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
