# GSA PIV auth proxy

This is a proxy that can be used to authenticate a user using their PIV
card and then pass the user on to the proxied service with the proper
headers set so that the app can authorize the user appropriately.

It downloads certs for the top level CA cert as well as some intermediate
certs and verifies their SHA using hashes found on https://fpki.idmanagement.gov/crls/.
Those SHAs may need to be updated if the root certs get updated.

## Configuration

The proxy is configred by:
* Setting three environment variables:
  * PROXY_URL:  This is the URL of the app that you want to proxy to, like https://foo.local/
  * PROXY_USERS: This is the list of users allowed into this service, space separated.
  * PROXY_NAME:  This is the name of the proxy.  It should be the same name as in the cert
* Ensuring that there are certs installed in /secrets/server.crt and /secrets/server.key.
  This is often done with setting a volume up or mounting a secret on /secrets.

If those things are set up, it should run and proxy stuff over.

