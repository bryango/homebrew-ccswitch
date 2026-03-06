cask "cc-switch" do
  version "3.11.1"
  sha256 "242bfddeb63632ead29b404fe827b5ec0dd28c13559899328351fa8ac59e1946"

  url "https://github.com/farion1231/cc-switch/releases/download/v#{version}/CC-Switch-v#{version}-macOS.tar.gz"
  name "CC Switch"
  desc "Configuration manager for Claude Code, Codex, Gemini CLI, OpenCode and OpenClaw"
  homepage "https://github.com/farion1231/cc-switch"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Verify the release asset was uploaded by GitHub Actions
  preflight do
    # Fetch latest release info from GitHub API
    release_info = JSON.parse(
      system_command("curl",
                     args:         ["--silent", "--location",
                                    "https://api.github.com/repos/farion1231/cc-switch/releases/latest"],
                     print_stderr: false).stdout,
    )

    # GitHub Actions bot ID and login
    github_actions_bot_id = 41898282
    github_actions_bot_login = "github-actions[bot]"

    # Check both the login and ID
    uploader = release_info.dig("author", "login")
    uploader_id = release_info.dig("author", "id")

    if uploader != github_actions_bot_login || uploader_id != github_actions_bot_id
      raise <<~EOS.chomp
        The release was not uploaded by the GitHub Actions bot.
        Current uploader: #{uploader} (ID: #{uploader_id})
        Expected: #{github_actions_bot_login} (ID: #{github_actions_bot_id})
        Please ensure the release was created via GitHub Actions workflow.
      EOS
    end
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
