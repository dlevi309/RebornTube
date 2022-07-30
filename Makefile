TARGET := iphone:clang:15.0:12.0
INSTALL_TARGET_PROCESSES = RebornTube
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = RebornTube
RebornTube_FILES = main.m $(shell find Classes -name '*.m') $(shell find Controllers -name '*.m')
RebornTube_FRAMEWORKS = UIKit Foundation AVFoundation AVKit Photos CoreGraphics AudioToolbox CFNetwork CoreFoundation CoreMedia CoreText CoreVideo OpenGLES QuartzCore Security VideoToolbox
RebornTube_LDFLAGS += -rpath @loader_path/Frameworks/
RebornTube_LIBRARIES = bz2 c++ iconv xml2
RebornTube_CFLAGS = -fobjc-arc
ARCHS = arm64

include $(THEOS_MAKE_PATH)/application.mk