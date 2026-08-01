cask "cc-switch" do
  version "3.19.1"
  sha256 "aa172d981c1cdca58d143ce36232ad26956a4e9ee77e3ed4ae2349ceeb2a074b"

  url "https://github.com/farion1231/cc-switch/releases/download/v#{version}/CC-Switch-v#{version}-macOS.tar.gz"
  name "CC Switch"
  desc "Configuration manager for Claude Code, Codex, Gemini CLI, OpenCode and OpenClaw"
  homepage "https://github.com/farion1231/cc-switch"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :monterey

  app "CC Switch.app"

  # Verify the release asset was uploaded by GitHub Actions
  preflight do
    github_token = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN") { ENV.fetch("GITHUB_TOKEN", nil) }
    curl_args = ["--fail", "--silent", "--location",
                 "--header", "Accept: application/vnd.github+json"]
    curl_args += ["--header", "Authorization: Bearer #{github_token}"] unless github_token.to_s.empty?
    curl_args << "https://api.github.com/repos/farion1231/cc-switch/releases/tags/v#{version}"

    # Fetch the cask's pinned release info from GitHub API
    release_info = JSON.parse(
      system_command("curl",
                     args:         curl_args,
                     must_succeed: true,
                     print_stderr: false,
                     secrets:      [github_token].compact).stdout,
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

  zap trash: [
    "~/.cc-switch",
    "~/Library/Application Support/com.ccswitch.desktop",
    "~/Library/Caches/com.ccswitch.desktop",
    "~/Library/Preferences/com.ccswitch.desktop.plist",
    "~/Library/Saved Application State/com.ccswitch.desktop.savedState",
    "~/Library/WebKit/com.ccswitch.desktop",
  ]
end
