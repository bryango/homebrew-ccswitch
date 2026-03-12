cask "cc-switch" do
  version "3.12.1"
  sha256 "ce03efee5177311bd4294d5d0d729445eaaf512d70d8218b8b534fc91ff80b88"

  url "https://github.com/farion1231/cc-switch/releases/download/v#{version}/CC-Switch-v#{version}-macOS.tar.gz"
  name "CC Switch"
  desc "Configuration manager for Claude Code, Codex, Gemini CLI, OpenCode and OpenClaw"
  homepage "https://github.com/farion1231/cc-switch"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :big_sur"

  app "CC Switch.app"

  zap trash: [
    "~/.cc-switch",
    "~/Library/Application Support/com.ccswitch.desktop",
    "~/Library/Caches/com.ccswitch.desktop",
    "~/Library/Preferences/com.ccswitch.desktop.plist",
    "~/Library/Saved Application State/com.ccswitch.desktop.savedState",
    "~/Library/WebKit/com.ccswitch.desktop",
  ]
end
