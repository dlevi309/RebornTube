set -e
curl -LO https://github.com/tanersener/ffmpeg-kit/releases/download/v4.5.1.LTS/ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip
curl -LO https://artifacts.videolan.org/VLCKit/dev-artifacts-MobileVLCKit-main/MobileVLCKit-4.0-20220629-0555.tar.xz
unzip ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip -d Resources/Frameworks
tar -xf MobileVLCKit-4.0-20220629-0555.tar.xz
mv MobileVLCKit-binary/MobileVLCKit.xcframework/ios-arm64_armv7/MobileVLCKit.framework Resources/Frameworks
rm -rf ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip MobileVLCKit-4.0-20220629-0555.tar.xz
echo Done