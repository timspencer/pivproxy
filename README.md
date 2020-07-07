# GSA PIV auth proxy

This is a proxy that can be used to authenticate a user using their PIV
card and then pass the user on to the proxied service with the proper
headers set so that the app can authorize the user appropriately.
If the certs verify AND the user is in the PROXY_USERS list, it will
let you through to the PROXY_URL application.

It downloads certs for the top level CA cert as well as some intermediate
certs and verifies their SHA using hashes found on https://fpki.idmanagement.gov/crls/.
Those SHAs may need to be updated if the root certs get updated.

## Building

The container can be built with `make build`.

You can test it by:
* Editing `docker-compose.yml` and setting your PIV card user in the list.
  (see `Proxy Users` section below for details on how to figure that out)
* Running `make build run`.
* If you go to https://localhost:4443/, you should be able to see a nice cat.
  If your user is not set up properly in the list, or you don't have your PIV card
  in, you should get a 403.

## Configuration

The proxy is configred by:
* Setting three environment variables:
  * `PROXY_URL`:  This is the URL of the app that you want to proxy to, like https://foo.local/
  * `PROXY_USERS`: This is the list of users allowed into this service, double quoted, comma delimited.
    Formatting is important here, because the data gets edited directly into the proxy.conf file.
    An example of this is `"UID=XXX+CN=TIM SPENCER,OU=General Services Administration,O=U.S. Government,C=US", "UID=..."`.
  * `PROXY_NAME`:  This is the name of the proxy.  It should be the same name as in the cert
* Ensuring that there are certs installed in /secrets/server.crt and /secrets/server.key.
  This is often done with setting a volume up or mounting a secret on /secrets.
* (Optional) Set the `PROXY_ALL_USERS` environment variable to `true` if you want the proxy to
  allow in _all_ users who's certs are verified, instead of just limiting it to the users in
  `PROXY_USERS`.

If those things are set up, it should run and proxy stuff over.

### Proxy Users

PROXY_USERS entries can be figured out with:
```
laptop:pivproxy$ pkcs11-tool --list-objects --type cert | grep subject 
Using slot 0 with a present token (0x0)
  subject:    DN: C=US, O=U.S. Government, OU=General Services Administration, CN=TIM SPENCER/UID=XXX
  subject:    DN: C=US, O=U.S. Government, OU=General Services Administration, CN=TIM SPENCER/UID=XXX
  subject:    DN: C=US, O=U.S. Government, OU=General Services Administration, CN=TIM SPENCER/UID=XXX
  subject:    DN: C=US, O=U.S. Government, OU=General Services Administration/serialNumber=XXX
laptop:pivproxy$ 
```

Apache seems to receive this in a format like:
```
UID=XXX+CN=TIM SPENCER,OU=General Services Administration,O=U.S. Government,C=US
```

So with a little fiddling, you should be able to rearrange things to get the cert name.  Or
just have the user go to the site, fail to auth, and look at the logs to see what the user field
was set to.
