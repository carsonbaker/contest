PCH = srtp.h
RANLIB = ranlib
CFLAGS = -Wall -Wextra -fPIC -fpic -Os -g
SYSROOT =
LIBS = -lpcap -lgcrypt
TGLIB = srtp.a

.PHONY: all clean
all: $(TGLIB)

$(TGLIB): srtp.o
	$(AR) cr $@ $^
	$(RANLIB) $@

%.o: %.c $(PCH).gch
	$(CC) $(CFLAGS) $(INCLUDE) $(SYSROOT) -c -o $@ $<

$(PCH).gch: $(PCH)
	$(CC) $(CFLAGS) $(INCLUDE) $(SYSROOT) -o $@ $<

clean:
	-rm *.o *.h.gch $(TGLIB) $(TEST)
