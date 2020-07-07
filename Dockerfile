FROM alpine:latest

RUN apk update
RUN apk add --no-cache --virtual .run-deps \
    ca-certificates apache2-ssl apache2-proxy openssl curl \
    && update-ca-certificates

# clean out the apache config dir
RUN mkdir -p /etc/apache2/conf.d.disabled ; mv /etc/apache2/conf.d/* /etc/apache2/conf.d.disabled/

# get the PIV root certs and verify it
# (from https://piv.idmanagement.gov/pivcertchains/#download-root-and-intermediate-certificates)
RUN curl -s http://http.fpki.gov/fcpca/fcpca.crt > /fcpca.crt
RUN sha1sum /fcpca.crt | grep 905f942fd9f28f679b378180fd4f846347f645c1 || false
RUN openssl x509 -in /fcpca.crt -inform der -outform pem -out /piv-root-certs.pem

# get the intermediate certs and verify them.
RUN curl -s http://http.fpki.gov/fcpca/caCertsIssuedByfcpca.p7c > /caCertsIssuedByfcpca.p7c
RUN sha1sum /caCertsIssuedByfcpca.p7c | grep e80ff80e3584da2a15f192b3194f9438e7394184 || false
RUN openssl pkcs7 -in /caCertsIssuedByfcpca.p7c -inform DER -print_certs -out /caCertsIssuedByfcpca.pem
RUN cat /caCertsIssuedByfcpca.pem >> /piv-root-certs.pem

RUN mkdir /secrets
COPY proxy.conf /etc/apache2/conf.d/proxy.conf

EXPOSE 4443
CMD ["httpd", "-DFOREGROUND"]
