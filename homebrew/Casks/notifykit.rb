cask "notifykit" do
  version "0.1.0"

  on_arm do
    sha256 "PLACEHOLDER_ARM64_SHA256" # arm64
    url "https://github.com/macalinao/notifykit/releases/download/v#{version}/NotifyKit-aarch64-apple-darwin.tar.gz"
  end

  on_intel do
    sha256 "PLACEHOLDER_X86_64_SHA256" # x86_64
    url "https://github.com/macalinao/notifykit/releases/download/v#{version}/NotifyKit-x86_64-apple-darwin.tar.gz"
  end

  name "NotifyKit"
  desc "macOS notification CLI with Claude Code hook support"
  homepage "https://github.com/macalinao/notifykit"

  # Extract and install the app
  app "NotifyKit.app"

  # Create CLI symlink
  binary "NotifyKit.app/Contents/MacOS/notifykit"

  postflight do
    # Ensure the binary is executable
    set_permissions "#{appdir}/NotifyKit.app/Contents/MacOS/notifykit", "755"
  end

  zap trash: [
    "~/Library/Application Support/NotifyKit",
    "~/Library/Preferences/com.macalinao.notifykit.plist",
  ]
end
