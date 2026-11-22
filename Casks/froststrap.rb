cask "froststrap" do
  arch arm: "arm64", intel: "x64"

  version "2.0.8"
  sha256 arm:   "007dcbedba08eed6c759c9144d55a78b494fb7120abd0812cf5690442a978f64",
         intel: "86e6eed7760a5c5f4af69489e3f3795ad1ca5eff1fe1c5115564d0a250ffb001"

  url "https://github.com/Froststrap/packages/releases/download/v#{version}/Froststrap-macos-#{arch}-Setup.pkg"
  name "Froststrap"
  desc "Roblox bootstrapper"
  homepage "https://github.com/Froststrap/Froststrap"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  conflicts_with cask: "froststrap@dev"
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
