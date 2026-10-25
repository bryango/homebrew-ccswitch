cask "cc-switch" do
  version "4.0.20"
  sha256 "dd6c1139cffc7fea820e01e93645a0db1509fb648411086aced334affcf6b0b6"

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
          release_info=$(/usr/bin/mktemp -t cc-switch-release)
          release_url="https://api.github.com/repos/farion1231/cc-switch/releases/tags/v{{version}}"
          trap 'rm -f "$release_info"' EXIT

          # Homebrew strips inherited secret variables from cask hooks.
          # An opt-in path to a 0600 HTTP header file can survive the sandbox,
          # without embedding the token in the cask's serialised install steps.
          credential_path="${HOMEBREW_CC_SWITCH_CREDENTIAL_PATH:-}"
          if [ -n "$credential_path" ]; then
            if [ ! -s "$credential_path" ]; then
              printf '%s\n' "GitHub credential header file is missing or empty." >&2
              exit 1
            fi
            printf '%s\n' "Checking release provenance via authenticated GitHub API." >&2
            # curl reads the Authorization header from the protected file, not argv.
            # Do not follow redirects to avoid forwarding it to another host.
            /usr/bin/curl --fail --silent --show-error --http1.1 \
              --retry 3 --retry-delay 1 --retry-all-errors \
              --header "Accept: application/vnd.github+json" \
              --header "@$credential_path" \
              --output "$release_info" \
              "$release_url"
          else
            printf '%s\n' "Checking release provenance via public GitHub API." >&2
            /usr/bin/curl --fail --silent --show-error --location --http1.1 \
              --retry 3 --retry-delay 1 --retry-all-errors \
              --header "Accept: application/vnd.github+json" \
              --output "$release_info" \
              "$release_url"
          fi

          release_tag=$(/usr/bin/plutil -extract tag_name raw -o - "$release_info")
          if [ "$release_tag" != "v{{version}}" ]; then
            printf 'Unexpected release tag: %s\n' "$release_tag" >&2
            exit 1
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
