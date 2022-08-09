TARGET := iphone:clang:15.5:15.0
INSTALL_TARGET_PROCESSES = RebornTubeSafariExt

include $(THEOS)/makefiles/common.mk

APPEX_NAME = RebornTubeSafariExt
RebornTubeSafariExt_FILES = SafariWebExtensionHandler.swift
RebornTubeSafariExt_INSTALL_PATH = /Applications/RebornTube.app/PlugIns
RebornTubeSafariExt_FRAMEWORKS = SafariServices
RebornTubeSafariExt_CFLAGS = -fobjc-arc
ARCHS = arm64

include $(THEOS_MAKE_PATH)/appex.mk