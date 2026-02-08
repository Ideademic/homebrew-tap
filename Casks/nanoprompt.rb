cask "nanoprompt" do
  version "0.4.1"

  on_arm do
    url "https://github.com/Ideademic/nanoprompt/releases/download/#{version}/nanoprompt_#{version}_aarch64.dmg"
  end

  on_intel do
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
