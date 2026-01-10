use anyhow::{Result, anyhow};
use block2::RcBlock;
use objc2::runtime::Bool;
use objc2_foundation::{NSError, NSString};
use objc2_user_notifications::{
    UNAuthorizationOptions, UNMutableNotificationContent, UNNotificationRequest,
    UNNotificationSound, UNTimeIntervalNotificationTrigger, UNUserNotificationCenter,
};
use std::sync::mpsc;
use std::time::Duration;

/// Converts an NSError pointer to a Result, using the provided context for the error message.
fn check_ns_error(error: *mut NSError, context: &str) -> Result<()> {
    if error.is_null() {
        Ok(())
    } else {
        let err = unsafe { &*error };
        Err(anyhow!("{}: {}", context, err.localizedDescription()))
    }
}

/// Sound options for notifications
pub enum NotificationSound {
    /// No sound
    None,
    /// Default system notification sound
    Default,
    /// Custom sound by name (must be in app bundle or system sounds)
    Custom(String),
}

/// Send a macOS notification using the User Notifications framework.
///
/// Note: The binary must be code-signed for notifications to appear.
/// Use `codesign --sign - --force <binary>` for ad-hoc signing.
pub fn send_notification(
    title: &str,
    subtitle: Option<&str>,
    body: Option<&str>,
    sound: NotificationSound,
) -> Result<()> {
    let center = UNUserNotificationCenter::currentNotificationCenter();

    // Request authorization synchronously using a channel
    let (auth_tx, auth_rx) = mpsc::channel();
    let auth_handler: RcBlock<dyn Fn(Bool, *mut NSError)> =
        RcBlock::new(move |granted: Bool, error: *mut NSError| {
            let result = check_ns_error(error, "Authorization error").and_then(|()| {
                if granted.as_bool() {
                    Ok(())
                } else {
                    Err(anyhow!("Notification permission denied"))
                }
            });
            let _ = auth_tx.send(result);
        });

    center.requestAuthorizationWithOptions_completionHandler(
        UNAuthorizationOptions::Alert | UNAuthorizationOptions::Sound,
        &auth_handler,
    );

    // Wait for authorization with timeout
    auth_rx
        .recv_timeout(Duration::from_secs(30))
        .map_err(|_| anyhow!("Authorization request timed out"))??;

    // Create notification content
    let content = UNMutableNotificationContent::new();
    content.setTitle(&NSString::from_str(title));
    if let Some(subtitle) = subtitle {
        content.setSubtitle(&NSString::from_str(subtitle));
    }
    if let Some(body) = body {
        content.setBody(&NSString::from_str(body));
    }

    // Set sound
    match sound {
        NotificationSound::None => {}
        NotificationSound::Default => {
            let sound = UNNotificationSound::defaultSound();
            content.setSound(Some(&sound));
        }
        NotificationSound::Custom(name) => {
            let sound = UNNotificationSound::soundNamed(&NSString::from_str(&name));
            content.setSound(Some(&sound));
        }
    }

    // Create trigger (fire immediately with minimal delay)
    let trigger = UNTimeIntervalNotificationTrigger::triggerWithTimeInterval_repeats(0.1, false);

    // Create request with unique identifier
    let request_id = format!("notifykit-{}", std::process::id());
    let request = UNNotificationRequest::requestWithIdentifier_content_trigger(
        &NSString::from_str(&request_id),
        &content,
        Some(&trigger),
    );

    // Add notification request synchronously using a channel
    let (add_tx, add_rx) = mpsc::channel();
    let add_handler: RcBlock<dyn Fn(*mut NSError)> = RcBlock::new(move |error: *mut NSError| {
        let _ = add_tx.send(check_ns_error(error, "Failed to add notification"));
    });

    center.addNotificationRequest_withCompletionHandler(&request, Some(&add_handler));

    // Wait for notification to be added with timeout
    add_rx
        .recv_timeout(Duration::from_secs(10))
        .map_err(|_| anyhow!("Add notification request timed out"))??;

    Ok(())
}
