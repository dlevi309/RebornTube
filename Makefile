TARGET := iphone:clang:15.5:13.0
INSTALL_TARGET_PROCESSES = RebornTube
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = RebornTube
RebornTube_FILES = main.m $(shell find Classes -name '*.m') $(shell find Controllers -name '*.m')
RebornTube_FRAMEWORKS = UIKit Foundation AVFoundation AVKit Photos CoreGraphics
RebornTube_WEAK_FRAMEWORKS = AVFAudio
# RebornTube_LDFLAGS += -rpath @loader_path/Frameworks/
RebornTube_CFLAGS = -fobjc-arc
ARCHS = arm64

include $(THEOS_MAKE_PATH)/application.mk
SUBPROJECTS += SafariExt
include $(THEOS_MAKE_PATH)/aggregate.mk