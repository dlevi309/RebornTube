set -e
rm -rf packages
make clean package FINALPACKAGE=1 PACKAGE_FORMAT=ipa
cd packages
wget https://github.com/tanersener/ffmpeg-kit/releases/download/v4.5.1.LTS/ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip
unzip h.lillie.reborntube_1.0.0.ipa
unzip ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip -d Frameworks
mv Frameworks Payload/RebornTube.app
zip -r RebornTube.ipa Payload
rm -rf Payload h.lillie.reborntube_1.0.0.ipa ffmpeg-kit-full-4.5.1.LTS-ios-framework.zip
cd ../
echo Done