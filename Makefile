ARCHS = arm64
TARGET = iphone:clang:16.5:10.0
THEOS_PACKAGE_DIR = /Users/pxx917144686/Downloads/pxx/packages

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = srlihg

srlihg_FILES = Tweak.xm
srlihg_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
