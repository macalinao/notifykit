use crate::cli::CchookArgs;
use crate::notification::{InterruptionLevel, NotificationSound, send_notification};
use anyhow::Result;
use serde::Deserialize;
use std::io::{self, Read};

/// Claude Code hook input structure.
/// See: https://code.claude.com/docs/en/hooks
#[derive(Deserialize)]
struct HookInput {
    session_id: String,
    hook_event_name: String,
    #[serde(default)]
    stop_hook_active: bool,
    /// Current working directory
    #[serde(default)]
    cwd: Option<String>,
    /// Message from Claude (e.g., "Claude needs your permission to use Bash")
    #[serde(default)]
    message: Option<String>,
    /// Notification type (e.g., "permission_prompt", "idle_prompt")
    #[serde(default)]
    notification_type: Option<String>,
}

pub fn run(args: CchookArgs) -> Result<()> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    // Raw mode: show stdin input directly for debugging
    if args.raw {
        let sound = match args.sound.as_deref() {
            None | Some("default") => NotificationSound::Default,
            Some("none") => NotificationSound::None,
            Some(name) => NotificationSound::Custom(name.to_string()),
        };

        let interruption_level = if args.banner {
            InterruptionLevel::Active
        } else {
            InterruptionLevel::TimeSensitive
        };

        return send_notification(
            "Claude Code (Raw)",
            None,
            Some(&input),
            sound,
            interruption_level,
            None, // No thread grouping in raw mode
        );
    }

    let hook: HookInput = serde_json::from_str(&input)?;

    // Prevent infinite loops if this is a stop hook
    if hook.stop_hook_active {
        return Ok(());
    }

    // Format notification based on hook event and notification type
    let title = format_title(&hook);
    let body = format_body(&hook);

    // Determine sound based on args
    let sound = match args.sound.as_deref() {
        None | Some("default") => NotificationSound::Default,
        Some("none") => NotificationSound::None,
        Some(name) => NotificationSound::Custom(name.to_string()),
    };

    let interruption_level = if args.banner {
        InterruptionLevel::Active
    } else {
        InterruptionLevel::TimeSensitive
    };

    // Use session_id as thread identifier to group notifications from the same session
    send_notification(
        &title,
        None,
        Some(&body),
        sound,
        interruption_level,
        Some(&hook.session_id),
    )
}

/// Format title based on notification type and event
fn format_title(hook: &HookInput) -> String {
    // Use notification_type for more specific titles
    if let Some(ref notification_type) = hook.notification_type {
        let type_label = match notification_type.as_str() {
            "permission_prompt" => "Permission Required",
            "idle_prompt" => "Waiting for Input",
            _ => notification_type.as_str(),
        };
        return format!("Claude Code: {}", type_label);
    }

    // Fall back to hook event name
    let event_label = match hook.hook_event_name.as_str() {
        "stop" => "Task Complete",
        "pre_tool_use" => "Tool Use",
        "post_tool_use" => "Tool Complete",
        "Notification" => "Notification",
        _ => &hook.hook_event_name,
    };
    format!("Claude Code: {}", event_label)
}

/// Format body with message and cwd
fn format_body(hook: &HookInput) -> String {
    let mut parts = Vec::new();

    // Add message if present
    if let Some(ref message) = hook.message {
        parts.push(message.clone());
    }

    // Add cwd if present (show just the last component for brevity)
    if let Some(ref cwd) = hook.cwd {
        let dir_name = std::path::Path::new(cwd)
            .file_name()
            .and_then(|n| n.to_str())
            .unwrap_or(cwd);
        parts.push(format!("📁 {}", dir_name));
    }

    if parts.is_empty() {
        "Claude Code".to_string()
    } else {
        parts.join("\n")
    }
}
