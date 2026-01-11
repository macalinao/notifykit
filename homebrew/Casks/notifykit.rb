cask "notifykit" do
  version "0.1.0"
  sha256 "PLACEHOLDER_ARM64_SHA256"

  url "https://github.com/macalinao/notifykit/releases/download/v#{version}/NotifyKit-aarch64-apple-darwin.tar.gz"
  name "NotifyKit"
  desc "macOS notification CLI with Claude Code hook support"
  homepage "https://github.com/macalinao/notifykit"

  depends_on arch: :arm64

  app "NotifyKit.app"
  binary "NotifyKit.app/Contents/MacOS/notifykit"

  postflight do
    set_permissions "#{appdir}/NotifyKit.app/Contents/MacOS/notifykit", "755"
  end

  zap trash: [
    "~/Library/Application Support/NotifyKit",
    "~/Library/Preferences/com.ianm.notifykit.plist",
  ]
end
