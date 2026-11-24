cask "froststrap@dev" do
  arch arm: "arm64", intel: "x64"

  version "2.0.9-beta.2"
  sha256 arm:   "7dd998cabd36a39a617056957959f45f2a19eedc6612a15f268f90a7055da6a2",
         intel: "c470b4ca3c87a94e4c161acfc3885bade2212b2b3f22157d00502858ebd1a4f7"

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
