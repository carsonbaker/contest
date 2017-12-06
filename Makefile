INCLUDE = -I/usr/local/opt/openssl/include
PKG_CONFIG_PATH ?= /usr/local/opt/openssl/lib/pkgconfig

.PHONY: libdtlsrtp

all: libdtlsrtp prompter

libdtls:
	$(MAKE) -C dtls

quick: prompter.cr src/*.cr
	crystal prompter.cr

prompter: prompter.cr src/*.cr
	shards
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) crystal build --release --no-debug prompter.cr
	@du -sh prompter
	
spec: all
	crystal spec

srv_test:
	pjsua --no-cli-console sip:srv_test@sip.getprompter.com

silent_test:
	pjsua --local-port=8873 --rtp-port=9100 --null-audio --no-cli-console --play-file=audio/audio-example.wav sip:carson@localhost

silent_test2:
	pjsua --local-port=8883 --rtp-port=9200 --null-audio --no-cli-console --play-file=audio/audio-example.wav sip:carson2@localhost

test_opus:
	pjsua --local-port=8903 --rtp-port=8532 --no-cli-console sip:carson@localhost

test_opus_record:
	pjsua --local-port=1234 --null-audio --rtp-port=8532 --no-cli-console --rec-file=opus.wav --auto-rec sip:carson@localhost

test:
	pjsua --dis-codec=opus --add-codec=pcmu/8000 --local-port=8833 --rtp-port=9000 --no-cli-console sip:carson@localhost

test_answer:
	pjsua --dis-codec=speex --add-codec=pcmu/8000 --quality=10 --auto-answer=200 --rtp-port=26000 --rec-file=rec.wav --auto-rec --play-file=audio/audio-example.wav --auto-play

test_record:
	pjsua --local-port=8883 --rtp-port=9300 --rec-file=rec.wav --auto-rec --null-audio sip:carson@localhost

loud_test:
	pjsua --local-port=8833 --rtp-port=9300 --no-cli-console sip:carson@localhost

web_test:
	/Applications/Firefox.app/Contents/MacOS/firefox-bin -P "Terminal" http://localhost:3000

3p_sip_session:
	pjsua --null-audio sip:904@mouselike.org 

run: prompter
	./prompter

clean:
	rm -rf prompter .crystal crul .deps .shards libs

PREFIX ?= /usr/local

install: prompter
	install -d $(PREFIX)/bin
	install prompter $(PREFIX)/bin
