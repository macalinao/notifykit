use anyhow::Result;
use std::fs;
use std::path::Path;

/// List available notification sounds on macOS
pub fn run() -> Result<()> {
    println!("Available notification sounds:\n");

    // Built-in options
    println!("Built-in:");
    println!("  default    - System default notification sound");
    println!("  none       - No sound");
    println!();

    // System sounds from /System/Library/Sounds
    let system_sounds_path = Path::new("/System/Library/Sounds");
    if system_sounds_path.exists() {
        println!("System sounds:");
        list_sounds_in_dir(system_sounds_path)?;
        println!();
    }

    // User sounds from ~/Library/Sounds
    if let Some(home) = std::env::var_os("HOME") {
        let user_sounds_path = Path::new(&home).join("Library/Sounds");
        if user_sounds_path.exists() {
            println!("User sounds:");
            list_sounds_in_dir(&user_sounds_path)?;
            println!();
        }
    }

    println!("Usage: notifykit send -t 'Title' -s <sound_name>");
    println!("       notifykit cchook -s <sound_name>");

    Ok(())
}

fn list_sounds_in_dir(dir: &Path) -> Result<()> {
    let mut sounds: Vec<String> = fs::read_dir(dir)?
        .filter_map(|entry| entry.ok())
        .filter_map(|entry| {
            let path = entry.path();
            if path.is_file() {
                path.file_stem()
                    .and_then(|s| s.to_str())
                    .map(|s| s.to_string())
            } else {
                None
            }
        })
        .collect();

    sounds.sort();

    for sound in sounds {
        println!("  {sound}");
    }

    Ok(())
}
