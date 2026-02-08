cask "nanoprompt" do
  version "0.4.0"

  on_arm do
    sha256 "a68658089649ccf3e6810466778f10645530c34bf2dad9117b6389b8ff4449df"
    url "https://github.com/Ideademic/nanoprompt/releases/download/#{version}/nanoprompt_#{version}_aarch64.dmg"
  end

  on_intel do
    sha256 "b85ebbe37a450ace1fabe194bbec1d0f16d737c8e63c687534bc7693f21c1ceb"
    url "https://github.com/Ideademic/nanoprompt/releases/download/#{version}/nanoprompt_#{version}_x64.dmg"
  end

  name "nanoprompt"
  desc "Minimalist terminal app that just works"
  homepage "https://github.com/Ideademic/nanoprompt"

  app "nanoprompt.app"

  zap trash: [
    "~/Library/Application Support/com.ideademic.nanoprompt",
    "~/Library/Caches/com.ideademic.nanoprompt",
    "~/Library/Preferences/com.ideademic.nanoprompt.plist",
  ]
end
