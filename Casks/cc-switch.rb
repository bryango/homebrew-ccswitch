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

  # Verify the release asset was uploaded by GitHub Actions
  preflight_steps do
    run "/bin/sh",
        args:           ["-eu", "-c", <<~'SH'],
          github_token="${HOMEBREW_GITHUB_API_TOKEN:-${GITHUB_TOKEN:-}}"
          release_info=$(/usr/bin/mktemp -t cc-switch-release)
          release_url="https://api.github.com/repos/farion1231/cc-switch/releases/tags/v{{version}}"
          trap 'rm -f "$release_info"' EXIT

          fetch_release() {
            if [ -n "$1" ]; then
              /usr/bin/curl --fail --silent --show-error --location --http1.1 \
                --retry 3 --retry-delay 1 --retry-all-errors \
                --header "Accept: application/vnd.github+json" \
                --header "Authorization: Bearer $1" \
                --output "$release_info" \
                "$release_url"
            else
              /usr/bin/curl --fail --silent --show-error --location --http1.1 \
                --retry 3 --retry-delay 1 --retry-all-errors \
                --header "Accept: application/vnd.github+json" \
                --output "$release_info" \
                "$release_url"
            fi
          }

          if [ -n "$github_token" ]; then
            if ! fetch_release "$github_token"; then
              printf '%s\n' "Authenticated GitHub API request failed; retrying anonymously." >&2
              fetch_release ""
            fi
          else
            fetch_release ""
          fi

          asset_name="CC-Switch-v{{version}}-macOS.tar.gz"
          index=0
          uploader=
          uploader_id=
          while name=$(/usr/bin/plutil -extract "assets.$index.name" raw -o - "$release_info" 2>/dev/null); do
            if [ "$name" = "$asset_name" ]; then
              uploader=$(/usr/bin/plutil -extract "assets.$index.uploader.login" raw -o - "$release_info")
              uploader_id=$(/usr/bin/plutil -extract "assets.$index.uploader.id" raw -o - "$release_info")
              break
            fi
            index=$((index + 1))
          done

          if [ -z "$uploader" ]; then
            printf 'Release asset not found: %s\n' "$asset_name" >&2
            exit 1
          fi

          if [ "$uploader" != "github-actions[bot]" ] || [ "$uploader_id" != "41898282" ]; then
            printf '%s\n' \
              "The release asset was not uploaded by the GitHub Actions bot." \
              "Current uploader: $uploader (ID: $uploader_id)" \
              "Expected: github-actions[bot] (ID: 41898282)" \
              "Please ensure the release asset was uploaded via GitHub Actions workflow." >&2
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
