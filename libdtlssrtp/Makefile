# Copyright (C) Richfit Information Technology Co.Ltd.
# Contributed by Xie Tianming <persmule@gmail.com>, 2015.

#  The DTLS-SRTP library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.

#  The DTLS-SRTP library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.

#  You should have received a copy of the GNU Lesser General Public
#  License along with the DTLS-SRTP library; if not, see
#  <http://www.gnu.org/licenses/>.

PCH = dtls_srtp.h
RANLIB = ranlib
CFLAGS = -Wall -Wextra -fPIC -fpic -O3
INCLUDE = -I/usr/local/opt/openssl/include 
SYSROOT =
LIBPATH = -L/usr/local/opt/openssl/lib
LIBS = -lcrypto -lssl
TGLIB = libdtlssrtp.a

.PHONY: all test clean
all: $(TGLIB)

$(TGLIB): dtls_srtp.o
	$(AR) cr $@ $^
	$(RANLIB) $@

%.o: %.c $(PCH).gch
	$(CC) $(CFLAGS) $(INCLUDE) $(SYSROOT) -c -o $@ $<

$(PCH).gch: $(PCH)
	$(CC) $(CFLAGS) $(INCLUDE) $(SYSROOT) -o $@ $<

clean:
	-rm *.o $(TGLIB)
