# docker-nextcloud
Docker setup for running Nextcloud behind a Traefik instance using PostgresQL as database and Redis as cache

## Setup
First we need to set up the TrueNAS NFS share that will store our user uploaded data
### TrueNAS NFS Share
We're using named docker volumes to store the cache, database and general Nextcloud config. For user uploaded data we're using an NFS share exported on our TrueNAS machine. Nextcloud runs as www-data with user:group 33:33 internally.

1. Create a dataset named `nextcloud`
1. Edit permissions for `nextcloud` and set User:Group to www-data:www-data
1. Create an NFS Share for the `nextcloud` dataset where `Mapall User` and `Mapall Group` are set to `www-data`, also set `Authorized Hosts` to your docker host's hostname (e.g. `dockerbox`)

### Docker setup
1. Initialize config files by running init.sh: `./init.sh`
1. Input your domain name and trusted local subnet in `.env`, also populate `ADMIN_USER` and `ADMIN_PASSWORD` with the credentials desired for the default admin account
1. Input your Postgres password in `secrets/POSTGRES_PASSWORD.secret` (create with e.g. `openssl rand 56 | base64`)
1. Make sure that Docker network `traefik` exists, `docker network ls`
1. Run `docker compose up` and check logs

### Email server
You can use Gmail's SMTP server for outgoing emails, it requires a Gmail account and an `app password`.

1. Go to `Administration settings->Basic settings` and scroll to the `Email server` section.
1. Fill out the fields:
    - Send mode: `SMTP`
    - Encryption: `SSL`
    - From address: `YOUREMAIL`@`gmail.com`
    - Server address: `smtp.gmail.com`:`465`
    - Authentication: Check `Authentication required`
    - Credentials: `YOUREMAIL@gmail.com` and your `app password`
1. Test your settings by clicking `Send email` at the bottom. The email of the account you're logged in as will receive a test email

### Maintenance window
Nextcloud can (and should) be configured so that maintenance tasks that aren't time-sensitive are ran during a period of expected low activity (i.e. at night).

The integer value at the end is the hour in UTC time when you want to 4 hours maintenance window to start (so `1` would mean 01:00-05:00 UTC): `docker compose exec -u www-data nextcloud php occ config:system:set maintenance_window_start --type=integer --value=0`

Additionally you need to set up the regular handling of maintenance tasks by adding
```
*/5 * * * * docker exec -u www-data nextcloud php /var/www/html/cron.php
```
to docker user crontab (`crontab -e`)

### Authentik
Check the [Authentik](https://github.com/znibb/docker-authentik?tab=readme-ov-file#432-nextcloud-settings) readme for how to setup user provisioning

## Troubleshooting
* Fix `no default phone region set`
1. `docker compose exec -u www-data nextcloud php occ config:system:set default_phone_region --type string --value="SE"`
1. `docker compose exec -u www-data nextcloud php occ maintenance:repair`

* Fix `One or more mimetype migrations are available`
1. `docker compose exec -u www-data nextcloud php occ maintenance:repair --include-expensive`

* Fix `Detected some missing optional indices`
1. `docker compose exec -u www-data nextcloud php occ db:add-missing-indices`