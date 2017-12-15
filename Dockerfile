FROM alpine
#RUN apk add --no-cache curl sudo bash

RUN wget http://public.portalier.com/alpine/julien@portalier.com-56dab02e.rsa.pub -O /etc/apk/keys/julien@portalier.com-56dab02e.rsa.pub
RUN echo http://public.portalier.com/alpine/testing >> /etc/apk/repositories
RUN apk update && apk add 'crystal=0.23.1-r1' gcc shards libgcrypt-dev automake alpine-sdk build-base opus-dev libxml2-dev openssl-dev libsamplerate-dev

RUN mkdir contest-build
ADD . contest-build
WORKDIR contest-build

RUN make

EXPOSE 49151-65535 5060 4000 3892


CMD ["make", "run"]
