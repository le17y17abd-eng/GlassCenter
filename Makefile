TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GlassCenter
GlassCenter_FILES = Tweak.xm GCWindow.m GCGlass.m GCSystem.m GCNowPlaying.m
GlassCenter_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable
GlassCenter_FRAMEWORKS = UIKit AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
