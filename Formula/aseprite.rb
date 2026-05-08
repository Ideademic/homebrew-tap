class Aseprite < Formula
  desc "Animated sprite editor & pixel art tool (compiled from source)"
  homepage "https://www.aseprite.org/"
  url "https://github.com/aseprite/aseprite/releases/download/v1.3.17.2/Aseprite-v1.3.17.2-Source.zip"
  sha256 "3895afca60608e86ffbba20c32af95a6e59f8d7ebe6d2617236f159b42176bfe"
  license :cannot_represent

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on :macos

  resource "skia" do
    on_arm do
      url "https://github.com/aseprite/skia/releases/download/m124-08a5439a6b/Skia-macOS-Release-arm64.zip"
      sha256 "22663000967fc2c3f1a78190082228474955de02ffd13a352b39a48b204dac9a"
    end
    on_intel do
      url "https://github.com/aseprite/skia/releases/download/m124-08a5439a6b/Skia-macOS-Release-x64.zip"
      sha256 "c11c5fbfa3f8cdefa2255d37cdd1eca823d195ff61929f457a4714f1b6db500a"
    end
  end

  def install
    skia_root = buildpath/"skia"
    skia_root.mkpath
    resource("skia").stage skia_root

    skia_arch = Hardware::CPU.arm? ? "arm64" : "x64"
    apple_arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
    skia_lib_dir = skia_root/"out/Release-#{skia_arch}"

    cmake_args = std_cmake_args + %W[
      -DCMAKE_BUILD_TYPE=RelWithDebInfo
      -DCMAKE_OSX_ARCHITECTURES=#{apple_arch}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0
      -DLAF_BACKEND=skia
      -DSKIA_DIR=#{skia_root}
      -DSKIA_LIBRARY_DIR=#{skia_lib_dir}
      -DSKIA_LIBRARY=#{skia_lib_dir}/libskia.a
      -DPNG_ARM_NEON:STRING=on
      -DENABLE_UPDATER=OFF
      -DENABLE_TESTS=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *cmake_args
    system "cmake", "--build", "build", "--config", "RelWithDebInfo", "--target", "aseprite"

    bin_dir = buildpath/"build/bin"
    binary = (bin_dir/"aseprite").exist? ? bin_dir/"aseprite" : bin_dir/"Aseprite"
    odie "build did not produce an aseprite binary" unless binary.exist?

    app = prefix/"Aseprite.app"
    macos_dir = app/"Contents/MacOS"
    resources_dir = app/"Contents/Resources"
    macos_dir.mkpath
    resources_dir.mkpath

    cp binary, macos_dir/"aseprite"
    chmod 0755, macos_dir/"aseprite"
    cp_r bin_dir/"data", macos_dir/"data"

    (app/"Contents/Info.plist").write info_plist
    (app/"Contents/PkgInfo").write "APPLAseP"

    system "/usr/bin/codesign", "--force", "--deep", "--sign", "-", app

    bin.install_symlink macos_dir/"aseprite"
  end

  def info_plist
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>CFBundleDevelopmentRegion</key><string>en</string>
          <key>CFBundleExecutable</key><string>aseprite</string>
          <key>CFBundleIdentifier</key><string>org.aseprite.Aseprite</string>
          <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
          <key>CFBundleName</key><string>Aseprite</string>
          <key>CFBundlePackageType</key><string>APPL</string>
          <key>CFBundleShortVersionString</key><string>#{version}</string>
          <key>CFBundleSignature</key><string>AseP</string>
          <key>CFBundleVersion</key><string>#{version}</string>
          <key>LSMinimumSystemVersion</key><string>11.0</string>
          <key>NSHighResolutionCapable</key><true/>
          <key>NSPrincipalClass</key><string>NSApplication</string>
        </dict>
      </plist>
    XML
  end

  def caveats
    <<~EOS
      Aseprite has been compiled from source.
        - CLI:        #{opt_bin}/aseprite

      Homebrew's sandbox prevents formulae from writing to ~/Applications,
      so install the bundle yourself with one of the commands below.

        # Copy into ~/Applications (real .app, recommended):
        mkdir -p ~/Applications && \\
          rm -rf ~/Applications/Aseprite.app && \\
          cp -R "#{opt_prefix}/Aseprite.app" ~/Applications/

        # Or symlink (auto-tracks `brew upgrade`, but it's a symlink):
        mkdir -p ~/Applications && \\
          ln -sfn "#{opt_prefix}/Aseprite.app" ~/Applications/Aseprite.app

      If you used `cp`, re-run it after `brew upgrade aseprite`.

      Aseprite is paid software; only the source is freely redistributable,
      which is why this is a formula (self-compiled) rather than a cask.
      EULA: https://github.com/aseprite/aseprite/blob/main/EULA.txt
    EOS
  end

  test do
    assert_match(/Aseprite/i, shell_output("#{bin}/aseprite --version 2>&1"))
  end
end
