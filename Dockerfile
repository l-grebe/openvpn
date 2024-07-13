# Original credit: https://github.com/jpetazzo/dockvpn

# build:
# docker build --file openvpn.dockerfile --tag openvpn:local .
# mac build:
# docker buildx build --platform linux/amd64 --file openvpn.dockerfile --tag openvpn:local .
# docker tag openvpn:local harbor.17zuoye.net/klx/openvpn:local
# docker push !$

# Smallest base image
FROM alpine:latest

# LABEL maintainer="Kyle Manna <kyle@kylemanna.com>"

# Testing: pamtester
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa openvpn-auth-pam google-authenticator pamtester libqrencode && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

ENTRYPOINT ["/start.sh"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Add support for OTP authentication using a PAM module
ADD ./otp/openvpn /etc/pam.d/
ADD start.sh /
# ADD ./local/configs /etc/openvpn/