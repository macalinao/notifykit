use crate::notification::{NotificationSound, send_notification};
use anyhow::Result;
use serde::Deserialize;
use std::io::{self, Read};

/// Claude Code hook input structure.
/// See: https://docs.anthropic.com/en/docs/claude-code/hooks
#[derive(Deserialize)]
struct HookInput {
    session_id: String,
    hook_event_name: String,
    #[serde(default)]
    stop_hook_active: bool,
}

pub fn run() -> Result<()> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let hook: HookInput = serde_json::from_str(&input)?;

    // Prevent infinite loops if this is a stop hook
    if hook.stop_hook_active {
        return Ok(());
    }

    // Format notification based on hook event
    let title = format!("Claude Code: {}", format_event_name(&hook.hook_event_name));
    // Use chars().take() to safely handle multi-byte UTF-8 characters
    let session_prefix: String = hook.session_id.chars().take(8).collect();
    let body = format!("Session: {}...", session_prefix);

    // Use default sound for Claude Code notifications
    send_notification(&title, None, Some(&body), NotificationSound::Default)
}

/// Format hook event name for display
fn format_event_name(event: &str) -> &str {
    match event {
        "stop" => "Task Complete",
        "pre_tool_use" => "Tool Use",
        "post_tool_use" => "Tool Complete",
        "notification" => "Notification",
        _ => event,
    }
}
