# certbot

[certbot](https://certbot.eff.org) is a tool to get free TLS encryption for your
websites. To install just follow their instructions on their
[website](https://certbot.eff.org).

If your site is already running you can just run `certbot` command and it'll
just give you the instruction on their program.

If you want to add certification first before enabling your site with nginx or
apache you can run 

```sh
sudo certbot certonly -d dev.example.com
```

Select the your web server and this will later create keys on the system that
you can use.

cert: `/etc/letsencrypt/live/dev.example.com/fullchain.pem`
key: `/etc/letsencrypt/live/dev.example.com/privkey.pem`

## NGINX

Create nginx config `/etc/sites-available/dev.example.com`

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name dev.example.com;
    return 301 https://dev.example.com$request_uri;
}

server {
    listen 443 ssl;
    root /var/www/dev.example.com/html;
    index index.html;
    server_name dev.example.com;

    location / {
        try_files $uri $uri/ $uri.html =404;
    }

    ssl_certificate /etc/letsencrypt/live/dev.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dev.example.com/privkey.pem;
}
```

To enable it you need to symlink it to `/etc/nginx/sites-enabled/dev.example.com`

```
sudo ln -s /etc/nginx/sites-available/dev.example.com /etc/nginx/sites-enabled/dev.example.com
```

