ARCHS = arm64 arm64e
TARGET = iphone:clang:15.0:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AdSkipTweak

AdSkipTweak_FILES = Tweak.xm AdSkipManager.m
AdSkipTweak_CFLAGS = -fobjc-arc -Wno-error
AdSkipTweak_FRAMEWORKS = UIKit Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
