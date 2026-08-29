ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
IGNORE_WARNINGS=0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AdSkipTweak

$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-arc-retain-cycles -Wno-error
$(TWEAK_NAME)_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_FRAMEWORKS = UIKit QuartzCore CoreGraphics AVFoundation WebKit

include $(THEOS_MAKE_PATH)/tweak.mk
