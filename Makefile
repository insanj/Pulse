THEOS_PACKAGE_DIR_NAME = debs
TARGET = :clang
ARCHS = armv7 arm64

TWEAK_NAME = Pulse
Pulse_FILES = Tweak.xm PLView.m
Pulse_FRAMEWORKS = UIKit CoreGraphics
Pulse_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-after-install::
	install.exec "killall -9 backboardd"