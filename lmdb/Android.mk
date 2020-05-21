LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := lmdb
LOCAL_SRC_FILES := \
	mdb.c \
	midl.c

include $(BUILD_SHARED_LIBRARY)