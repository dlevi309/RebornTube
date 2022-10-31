TARGET = iphone:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

APPEX_NAME = fiore
fiore_FILES = fiore.swift
fiore_INSTALL_PATH = /Applications/tomato.app/PlugIns
fiore_SWIFTFLAGS += -parse-as-library

include $(THEOS_MAKE_PATH)/appex.mk