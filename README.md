Customized:

 themes/next/layout/_partials/head/custom-head.swig

```html
<link rel="pgpkey" type="application/pgp-keys" href="/key.pub">
```

```bash
echo '(challenge text from indieauth.com)' | gpg --clearsign --armor
```

## Set up using IndieAuth.com(TODO)

IndieAuth.com is a service that allows you to sign in as your site by using your social media profiles. Your homepage and social media profiles need to link to each other for verification. Instead of registering for an account at indieauth.com, it uses your existing social media accounts to verify you own the URL you're signing in as.

1. Add rel-me links to your homepage for various ways to reach you,
e.g. <a href="https://github.com/aaronpk" rel="me">GitHub</a>.
Make sure any social media profiles you linked to have a link back to your homepage.
2. Finally, include <link rel="authorization_endpoint" href="https://indieauth.com/auth"> on your homepage.
