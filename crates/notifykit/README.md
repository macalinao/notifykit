# NotifyKit

A macOS notification CLI with Claude Code hook support. Built with Rust using the native `UserNotifications` framework.

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/macalinao/notifykit/master/scripts/install-remote.sh | bash
```

### Using Nix

```bash
nix run github:macalinao/notifykit
```

See the [full README](https://github.com/macalinao/notifykit) for more installation options.

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

### Claude Code Hook

NotifyKit can notify you when [Claude Code](https://docs.anthropic.com/en/docs/claude-code/hooks) finishes a task.

Add to `~/.claude/settings.json`:

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

### List Available Sounds

```bash
notifykit sounds
```

Available sounds: `default`, `Basso`, `Blow`, `Bottle`, `Frog`, `Funk`, `Glass`, `Hero`, `Morse`, `Ping`, `Pop`, `Purr`, `Sosumi`, `Submarine`, `Tink`

## Why an App Bundle?

The modern `UserNotifications` framework requires the calling process to be part of a signed app bundle. NotifyKit is packaged as `NotifyKit.app` with the CLI binary inside.

## License

Apache-2.0
