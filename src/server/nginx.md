# nginx

Setup simple nginx web server.

## Debian

### Step 1 - Installation

Update package index.

```
sudo apt update
```

Install `nginx`

```
sudo apt install nginx
```

### Step 2 - Setup Firewall

List application configuration with `ufw`

```
sudo ufw app list
```

Enable nginx on port `80`

```
sudo ufw allow 'Nginx HTTP'
```

Check the firewall status

```
sudo ufw status
```

### Step 3 - Check web server

Check with `systemd` if the service is running

```
systemctl status nginx
```

## Some nginx commands

Test the config file

```
nginx -t
```

Reload the service with the new config file

```
nginx -s reload
```

## Configure

The default nginx configuration is setup to include sites under
`/etc/nginx/sites-enabled`. In this location the sites is usually symlink from
`/etc/nginx/sites-available`. The file that configure this behavior is
`/etc/nginx/nginx.conf` at line `include /etc/nginx/sites-enabled/*`.

### Sites

To add new site to nginx add a new file in `/etc/nginx/sites-available`

```
/etc/nginx/sites-available
```

There should a `default` site already there which can be use as base.

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

