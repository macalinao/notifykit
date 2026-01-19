# NotifyKit

A macOS notification CLI with Claude Code hook support. Built with Rust using the native `UserNotifications` framework.

## Installation

### Using Nix (Recommended)

For faster builds, add the Cachix cache first:

```bash
cachix use igm
```

#### Flake

Add to your flake inputs:

```nix
{
  inputs.notifykit.url = "github:macalinao/notifykit";
}
```

Then add to your packages:

```nix
environment.systemPackages = [ inputs.notifykit.packages.${system}.default ];
```

#### Run directly

```bash
nix run github:macalinao/notifykit
```

### Quick Install (from releases)

```bash
curl -fsSL https://raw.githubusercontent.com/macalinao/notifykit/master/scripts/install-remote.sh | bash
```

### Manual Install (from releases)

1. Download the latest release from [GitHub Releases](https://github.com/macalinao/notifykit/releases):
   - `NotifyKit-aarch64-apple-darwin.tar.gz` (Apple Silicon)
   - `NotifyKit-x86_64-apple-darwin.tar.gz` (Intel)

2. Extract and install:

```bash
# Extract
tar -xzf NotifyKit-*.tar.gz

# Move to Applications
mv NotifyKit.app ~/Applications/

# Create symlink (needs sudo)
sudo ln -sf ~/Applications/NotifyKit.app/Contents/MacOS/notifykit /usr/local/bin/notifykit

# Verify
notifykit --version
```

### From Source

```bash
git clone https://github.com/macalinao/notifykit
cd notifykit
./scripts/install --release
```

### First Run

On first run, macOS will ask for notification permissions. If notifications don't appear, enable them manually:

**System Settings → Notifications → NotifyKit**

## Usage

### Send a Notification

```bash
# Basic notification
notifykit send -t "Hello" -b "World"

# With sound
notifykit send -t "Alert" -b "Something happened" -s default

# With subtitle
notifykit send -t "Title" --subtitle "Subtitle" -b "Body" -s default
```

### Options

```
notifykit send [OPTIONS] --title <TITLE>

Options:
  -t, --title <TITLE>        Notification title (required)
  -b, --body <BODY>          Notification body
      --subtitle <SUBTITLE>  Notification subtitle
  -s, --sound <SOUND>        Sound: "default" or custom sound name
  -h, --help                 Print help
```

## Claude Code Hook

NotifyKit can be used as a [Claude Code hook](https://docs.anthropic.com/en/docs/claude-code/hooks) to get notifications when Claude completes tasks.

### Setup

Add to your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "stop": [
      {
        "type": "command",
        "command": "notifykit cchook"
      }
    ]
  }
}
```

Now you'll get a notification (with sound) whenever Claude finishes a task.

### Custom Sound

Use a custom notification sound:

```json
{
  "hooks": {
    "stop": [
      {
        "type": "command",
        "command": "notifykit cchook --sound Glass"
      }
    ]
  }
}
```

To see all available sounds:

```bash
notifykit sounds
```

Available options:

- `default` - System default notification sound
- `none` - No sound
- System sounds: `Basso`, `Blow`, `Bottle`, `Frog`, `Funk`, `Glass`, `Hero`, `Morse`, `Ping`, `Pop`, `Purr`, `Sosumi`, `Submarine`, `Tink`

### Multiple Hook Events

You can set up notifications for different Claude Code events:

```json
{
  "hooks": {
    "stop": [
      {
        "type": "command",
        "command": "notifykit cchook --sound Glass"
      }
    ],
    "notification": [
      {
        "type": "command",
        "command": "notifykit cchook --sound Ping"
      }
    ]
  }
}
```

### Hook Events

The `cchook` command reads Claude Code hook JSON from stdin and sends appropriate notifications:

- `stop` → "Task Complete"
- `notification` → "Notification"
- Other events are displayed as-is

## Development

### Prerequisites

- Rust (via rustup)
- macOS (required for UserNotifications framework)

### Build

```bash
# Development build
cargo build

# Create .app bundle for testing
cargo bundle -p notifykit

# Install locally (release build, or --debug for debug)
./scripts/install
```

### Project Structure

```
notifykit/
├── crates/
│   └── notifykit/          # Main CLI crate
│       └── src/
│           ├── main.rs
│           ├── cli.rs      # CLI argument definitions
│           ├── notification.rs  # macOS notification API
│           └── commands/
│               ├── send.rs     # send command
│               ├── cchook.rs   # Claude Code hook
│               └── sounds.rs   # list available sounds
├── resources/
│   ├── Info.plist          # macOS app bundle metadata
│   └── NotifyKit.icns      # App icon
├── scripts/
│   ├── install             # Local install (uses cargo-bundle)
│   └── install-remote.sh   # Remote install script
├── flake.nix               # Nix flake
├── package.nix             # Nix derivation (nixpkgs-compatible)
├── devenv.nix              # Nix development environment
└── Cargo.toml              # Workspace configuration
```

### Why an App Bundle?

The modern `UserNotifications` framework requires the calling process to be part of a signed app bundle. NotifyKit is packaged as `NotifyKit.app` with the CLI binary inside. The install scripts create a symlink so you can use `notifykit` directly from your terminal.

## License

Apache-2.0
