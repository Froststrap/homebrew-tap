cask "froststrap@dev" do
  arch arm: "arm64", intel: "x64"

  version "2.0.9-beta.1"
  sha256 arm:   "8f67a44a8891d772247200a078e4d777e49ce0ee8dcd7f3dbcc0fa6da1ed548b",
         intel: "7971d70276cf68db29ba279e3f3b9d02f2d7a269d34598a8887d526ec07f9778"

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
