TARGET := iphone:clang:latest:14.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = NaverCafeLite

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = NaverCafeLite

NaverCafeLite_FILES = main.m AppDelegate.m WebViewController.m
NaverCafeLite_FRAMEWORKS = UIKit WebKit
NaverCafeLite_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk
