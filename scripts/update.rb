#!/usr/bin/env ruby
require "digest"
require "json"
require "open-uri"

REPO = "Froststrap/packages"
ARCHES = { arm: "arm64", intel: "x64" }.freeze
CASKS = File.expand_path("../Casks", __dir__)

def api(path)
  headers = { "Accept" => "application/vnd.github+json" }
  headers["Authorization"] = "Bearer #{ENV["GITHUB_TOKEN"]}" if ENV["GITHUB_TOKEN"]
  JSON.parse(URI.open("https://api.github.com/repos/#{REPO}/#{path}", headers).read)
end

def pkg(tag, arch)
  "https://github.com/#{REPO}/releases/download/#{tag}/Froststrap-macos-#{arch}-Setup.pkg"
end

def macos?(release)
  names = release["assets"].map { |asset| asset["name"] }
  ARCHES.values.all? { |arch| names.include?("Froststrap-macos-#{arch}-Setup.pkg") }
end

def write_cask(token, release, name:, desc:, livecheck:, conflicts:)
  version = release["tag_name"].delete_prefix("v")
  path = File.join(CASKS, "#{token}.rb")
  return puts("#{token} already at #{version}") if File.exist?(path) && File.read(path).include?(%(version "#{version}"))

  sha = ARCHES.transform_values { |arch| Digest::SHA256.hexdigest(URI.open(pkg(release["tag_name"], arch)).read) }

  File.write(path, <<~RUBY)
    cask "#{token}" do
      arch arm: "arm64", intel: "x64"

      version "#{version}"
      sha256 arm:   "#{sha[:arm]}",
             intel: "#{sha[:intel]}"

      url "https://github.com/#{REPO}/releases/download/v\#{version}/Froststrap-macos-\#{arch}-Setup.pkg"
      name "#{name}"
      desc "#{desc}"
      homepage "https://github.com/Froststrap/Froststrap"

      livecheck do
        #{livecheck}
      end

      auto_updates true
      conflicts_with cask: "#{conflicts}"
      depends_on macos: ">= :big_sur"

      pkg "Froststrap-macos-\#{arch}-Setup.pkg"

      uninstall quit:    "xyz.froststrap.desktop",
                pkgutil: "xyz.froststrap.desktop",
                delete:  "/Applications/Froststrap.app"

      zap trash: [
        "~/Library/Application Support/Froststrap",
        "~/Library/Preferences/xyz.froststrap.desktop.plist",
        "~/Library/Saved Application State/xyz.froststrap.desktop.savedState",
      ]
    end
  RUBY
  puts "#{token} -> #{version}"
end

stable = api("releases/latest")
dev = api("releases?per_page=100").reject { |r| r["draft"] }.select { |r| macos?(r) }.max_by { |r| r["published_at"] }

write_cask "froststrap", stable,
           name: "Froststrap", desc: "Roblox bootstrapper",
           livecheck: "url :url\n    strategy :github_latest", conflicts: "froststrap@dev" if macos?(stable)

write_cask "froststrap@dev", dev,
           name: "Froststrap (dev)", desc: "Roblox bootstrapper (latest release, including pre-releases)",
           livecheck: %(skip "Updated by the tap update workflow"), conflicts: "froststrap"
