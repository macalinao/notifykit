mod cli;
mod commands;
mod notification;

use anyhow::Result;
use clap::Parser;
use cli::{Cli, Commands};

fn main() -> Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Send(args) => commands::send::run(args),
        Commands::Cchook => commands::cchook::run(),
    }
}
