# Makefile for the ATSC 3.0 LLS Parser with AC-4 Parser

# Compiler and Flags
CC = gcc
UNAME_S := $(shell uname -s)

# macOS: Homebrew installs OpenSSL "keg-only" (not linked into the default
# include/lib paths), so point the compiler and linker at it explicitly.
ifeq ($(UNAME_S),Darwin)
    OPENSSL_PREFIX := $(shell brew --prefix openssl 2>/dev/null)
    ifneq ($(wildcard $(OPENSSL_PREFIX)/include/openssl),)
        OPENSSL_CFLAGS := -I$(OPENSSL_PREFIX)/include
        OPENSSL_LDFLAGS := -L$(OPENSSL_PREFIX)/lib
    endif
endif

# libhdhomerun: link the system library (libhdhomerun-dev on Linux). On macOS,
# where there is usually no working packaged library, a copy of the SiliconDust
# source in ./libhdhomerun (git clone https://github.com/Silicondust/libhdhomerun)
# is compiled into a static library instead.
HDHOMERUN_LIB = -lhdhomerun
ifeq ($(UNAME_S),Darwin)
    ifneq ($(wildcard libhdhomerun/hdhomerun.h),)
        LIBHDHOMERUN_A = libhdhomerun/libhdhomerun.a
        HDHOMERUN_LIB = $(LIBHDHOMERUN_A)
        HDHOMERUN_SRCS = $(addprefix libhdhomerun/, \
            hdhomerun_channels.c hdhomerun_channelscan.c hdhomerun_control.c \
            hdhomerun_debug.c hdhomerun_device.c hdhomerun_device_selector.c \
            hdhomerun_discover.c hdhomerun_os_posix.c hdhomerun_pkt.c \
            hdhomerun_sock.c hdhomerun_sock_posix.c hdhomerun_sock_getifaddrs.c \
            hdhomerun_video.c)
        HDHOMERUN_OBJS = $(HDHOMERUN_SRCS:.c=.o)
    endif
endif

CFLAGS = -Wall -g -Ilibhdhomerun $(OPENSSL_CFLAGS) $(shell pkg-config --cflags libxml-2.0 libavcodec libavutil)
LDFLAGS = $(shell pkg-config --libs libxml-2.0 libavcodec libavutil) -lpcap -lz $(OPENSSL_LDFLAGS) -lssl -lcrypto $(HDHOMERUN_LIB) -lcurl -lm

# Source files
SRCS = a3render.c mmt.c input.c plp.c l1_detail_parser.c crypto.c esg.c bps.c egps.c utility.c direct_parsers.c

# Object files (automatically derived from SRCS)
OBJS = $(SRCS:.c=.o)

# Header files (for dependency tracking)
HEADERS = structures.h mmt.h input.h plp.h l1_detail_parser.h crypto.h esg.h bps.h egps.h utility.h direct_parsers.h

# Executable
TARGET = render

# Default target: build the executable
all: $(TARGET)

# Build the executable from object files
$(TARGET): $(OBJS) $(LIBHDHOMERUN_A)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDFLAGS)

# Static libhdhomerun from bundled source (macOS only, see above)
ifdef LIBHDHOMERUN_A
$(LIBHDHOMERUN_A): $(HDHOMERUN_OBJS)
	$(AR) rcs $@ $^

libhdhomerun/%.o: libhdhomerun/%.c
	$(CC) -O2 -Wall -c $< -o $@
endif

# Pattern rule for building object files from C source files
%.o: %.c $(HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

# Target to clean up the build directory
clean:
	rm -f $(TARGET) $(OBJS) $(LIBHDHOMERUN_A) $(HDHOMERUN_OBJS)

# Target to rebuild everything from scratch
rebuild: clean all

# Phony targets
.PHONY: all clean rebuild
