cask "cc-switch" do
  version "3.20.3"
  sha256 "8f00554cfddf585fa672e5e7d21db0e84ae410e02d127b96ce0211013734568f"

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

  # Verify the release was uploaded by GitHub Actions
  preflight_steps do
    run "/bin/sh",
        args: ["-eu", "-c", <<~'SH'],
          github_token="${HOMEBREW_GITHUB_API_TOKEN:-${GITHUB_TOKEN:-}}"
          release_info=$(/usr/bin/mktemp -t cc-switch-release)
          trap 'rm -f "$release_info"' EXIT

          set -- --fail --silent --location \
            --header "Accept: application/vnd.github+json"
          if [ -n "$github_token" ]; then
            set -- "$@" --header "Authorization: Bearer $github_token"
          fi

          /usr/bin/curl "$@" \
            --output "$release_info" \
            "https://api.github.com/repos/farion1231/cc-switch/releases/tags/v{{version}}"

          uploader=$(/usr/bin/plutil -extract author.login raw -o - "$release_info")
          uploader_id=$(/usr/bin/plutil -extract author.id raw -o - "$release_info")

          if [ "$uploader" != "github-actions[bot]" ] || [ "$uploader_id" != "41898282" ]; then
            printf '%s\n' \
              "The release was not uploaded by the GitHub Actions bot." \
              "Current uploader: $uploader (ID: $uploader_id)" \
              "Expected: github-actions[bot] (ID: 41898282)" \
              "Please ensure the release was created via GitHub Actions workflow." >&2
            exit 1
          fi
        SH
        network_access: true
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
