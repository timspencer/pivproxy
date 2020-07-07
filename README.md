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
  * PROXY_USERS: This is the list of users allowed into this service, double quoted, space separated
    (formatting is important here, because the data gets sedded into the conf file).
    An example of this is `"UID=XXX+CN=TIM SPENCER,OU=General Services Administration,O=U.S. Government,C=US", "UID=..."`.  You may have to put single quotes around this depending on
    how you are setting this environment variable.
  * PROXY_NAME:  This is the name of the proxy.  It should be the same name as in the cert
* Ensuring that there are certs installed in /secrets/server.crt and /secrets/server.key.
  This is often done with setting a volume up or mounting a secret on /secrets.

If those things are set up, it should run and proxy stuff over.

PROXY_USERS can be figured out with:
```
laptop:pivproxy$ pkcs11-tool --list-objects --type cert | grep subject 
Using slot 0 with a present token (0x0)
  subject:    DN: C=US, O=U.S. Government, OU=General Services Administration, CN=TIM SPENCER/UID=XXX
  subject:    DN: C=US, O=U.S. Government, OU=General Services Administration, CN=TIM SPENCER/UID=XXX
  subject:    DN: C=US, O=U.S. Government, OU=General Services Administration, CN=TIM SPENCER/UID=XXX
  subject:    DN: C=US, O=U.S. Government, OU=General Services Administration/serialNumber=XXX
laptop:pivproxy$ 
```

Apache seems to reformat this to a format like this:
```
UID=XXX+CN=TIM SPENCER,OU=General Services Administration,O=U.S. Government,C=US
```

So with a little fiddling, you should be able to rearrange things to get the cert name.  Or
just have the user go to the site, fail to auth, and look at the logs to see what the user field
was set to.
