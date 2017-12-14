CONTEST
======= 
CarsON's TElephony STack

## Description
This is a experimental VoIP server to explore WebRTC concepts.

## Setup
1. Generate certs [todo]
2. Configure src/conf.cr
3. `make`
4. `make spec`
5. `make run`

## Requirements
`brew install libsamplerate opus-dev openssl libgcrypt pcre`

For testing:
`brew install pjproject`

## Crystal Bugs
On Mac OS X, I had to find Crystal installation and change:

* line 11 of lib_event2.cr from:
```@[Link("event")]```
to:
```@[Link("libevent")]```

* line 5 of boehm.cr from:
```  @[Link("gc")]```
to:
```@[Link("bdw-gc")]```
