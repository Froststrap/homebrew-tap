cask "froststrap@dev" do
  arch arm: "arm64", intel: "x64"

  version "2.0.9-beta.3"
  sha256 arm:   "1539ae815e2b23f653c22c737cb95a1f15c57604ae4a965bb82419d15a35ac71",
         intel: "473169a80ed69126ec8c03a5f2b3773add9041220ebe9ebfcc925fb87425115c"

  url "https://github.com/Froststrap/packages/releases/download/v#{version}/Froststrap-macos-#{arch}-Setup.pkg"
  name "Froststrap (dev)"
  desc "Roblox bootstrapper (latest release, including pre-releases)"
  homepage "https://github.com/Froststrap/Froststrap"

  livecheck do
    skip "Updated by the tap update workflow"
  end

  auto_updates true
  conflicts_with cask: "froststrap"
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
