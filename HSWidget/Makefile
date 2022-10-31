TARGET := iphone:clang:15.5:15.0
INSTALL_TARGET_PROCESSES = RebornTubeHSWidget

include $(THEOS)/makefiles/common.mk

APPEX_NAME = RebornTubeHSWidget
RebornTubeHSWidget_FILES = HomeScreenWidgetHandler.swift
RebornTubeHSWidget_INSTALL_PATH = /Applications/RebornTube.app/PlugIns
RebornTubeHSWidget_SWIFTFLAGS += -parse-as-library
RebornTubeHSWidget_CFLAGS = -fobjc-arc
ARCHS = arm64

include $(THEOS_MAKE_PATH)/appex.mk