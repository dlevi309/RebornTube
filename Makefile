TARGET := iphone:clang:15.5:13.0
INSTALL_TARGET_PROCESSES = RebornTube
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = RebornTube
RebornTube_FILES = main.m $(shell find Classes -name '*.m') $(shell find Controllers -name '*.m') $(shell find Views -name '*.m') $(shell find AFNetworking -name '*.m')
RebornTube_FRAMEWORKS = UIKit Foundation AVFoundation AVKit Photos CoreGraphics Accelerate AudioToolbox CFNetwork CoreFoundation CoreMedia CoreMotion CoreText CoreVideo OpenGLES QuartzCore Security VideoToolbox
RebornTube_WEAK_FRAMEWORKS = AVFAudio
RebornTube_EXTRA_FRAMEWORKS = MobileVLCKit ffmpegkit libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale
RebornTube_LDFLAGS += -FResources/Frameworks -rpath @loader_path/Frameworks/
RebornTube_LIBRARIES = bz2 c++ iconv xml2 z
RebornTube_CFLAGS = -FResources/Frameworks -fobjc-arc -Wno-incomplete-implementation
ARCHS = arm64

include $(THEOS_MAKE_PATH)/application.mk
SUBPROJECTS += HSWidget SafariExt
include $(THEOS_MAKE_PATH)/aggregate.mk