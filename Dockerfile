FROM alpine
#RUN apk add --no-cache curl sudo bash

RUN wget http://public.portalier.com/alpine/julien@portalier.com-56dab02e.rsa.pub -O /etc/apk/keys/julien@portalier.com-56dab02e.rsa.pub
RUN echo http://public.portalier.com/alpine/testing >> /etc/apk/repositories
RUN apk update && apk add 'crystal=0.23.1-r1' gcc shards libgcrypt-dev
RUN apk add automake alpine-sdk build-base
RUN apk add opus-dev
RUN apk add libxml2-dev
RUN apk add openssl-dev
RUN apk add libsamplerate-dev 

ADD . /contest
WORKDIR /contest

RUN make all
RUN make spec
RUN make run
