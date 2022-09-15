set -e
rm -rf Resources/Frameworks Temp ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip Sentry.framework.zip
curl -LO https://github.com/tanersener/ffmpeg-kit/releases/download/v4.5.1.LTS/ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip
curl -LO https://github.com/getsentry/sentry-cocoa/releases/download/7.25.1/Sentry.framework.zip
unzip ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip -d Resources/Frameworks
unzip Sentry.framework.zip -d Temp
mv Temp/Carthage/Build/iOS/Sentry.framework Resources/Frameworks
rm -rf Temp ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip Sentry.framework.zip
echo Done