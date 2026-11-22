#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-Froststrap/packages}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

has_macos='[.assets[].name] | (index("Froststrap-macos-arm64-Setup.pkg") != null and index("Froststrap-macos-x64-Setup.pkg") != null)'

stable_tag=$(gh api "repos/$REPO/releases/latest" --jq "select($has_macos) | .tag_name")
dev_tag=$(gh api "repos/$REPO/releases?per_page=100" --paginate \
  | jq -rs "add | map(select(.draft | not) | select($has_macos)) | sort_by(.published_at) | last | .tag_name")

sha() {
  curl -fsSL "https://github.com/$REPO/releases/download/$1/Froststrap-macos-$2-Setup.pkg" | shasum -a 256 | cut -d' ' -f1
}

write_cask() {
  local token=$1 tag=$2 name=$3 desc=$4 livecheck=$5 conflicts=$6
  local version=${tag#v}
  local current="$ROOT/Casks/$token.rb"

  if [[ -f "$current" ]] && grep -q "version \"$version\"" "$current"; then
    echo "$token already at $version"
    return
  fi

  local arm intel
  arm=$(sha "$tag" arm64)
  intel=$(sha "$tag" x64)

  cat > "$current" <<CASK
cask "$token" do
  arch arm: "arm64", intel: "x64"

  version "$version"
  sha256 arm:   "$arm",
         intel: "$intel"

  url "https://github.com/$REPO/releases/download/v#{version}/Froststrap-macos-#{arch}-Setup.pkg"
  name "$name"
  desc "$desc"
  homepage "https://github.com/Froststrap/Froststrap"

$livecheck

  auto_updates true
  conflicts_with cask: "$conflicts"
  depends_on macos: ">= :big_sur"

  pkg "Froststrap-macos-#{arch}-Setup.pkg"

  uninstall quit:    "xyz.froststrap.desktop",
            pkgutil: "xyz.froststrap.desktop",
            delete:  "/Applications/Froststrap.app"

  zap trash: [
    "~/Library/Application Support/Froststrap",
    "~/Library/Preferences/xyz.froststrap.desktop.plist",
    "~/Library/Saved Application State/xyz.froststrap.desktop.savedState",
  ]
end
CASK
  echo "$token -> $version"
}

write_cask froststrap "$stable_tag" "Froststrap" "Roblox bootstrapper" '  livecheck do
    url :url
    strategy :github_latest
  end' "froststrap@dev"

write_cask "froststrap@dev" "$dev_tag" "Froststrap (dev)" "Roblox bootstrapper (latest release, including pre-releases)" '  livecheck do
    skip "Updated by the tap update workflow"
  end' froststrap
