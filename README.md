# docker-nextcloud
Docker setup for running Nextcloud behind a Traefik instance using PostgresQL as database and Redis as cache

## Setup
1. Initialize config files by running init.sh: `./init.sh`
1. Input your domain name and trusted local subnet in `.env`
1. Input your Postgres password in `secrets/POSTGRES_PASSWORD.secret`
1. Make sure that Docker network `traefik` exists, `docker network ls`
1. Run `docker compose up` and check logs

## Troubleshooting
* Fix "no default phone region set"
1. `docker compose exec -u www-data nextcloud php occ config:system:set default_phone_region --type string --value="SE"`
1. `docker compose exec -u www-data nextcloud php occ maintenance:repair`

* Setup background cron job
1. Add `*/5 * * * * docker exec -u www-data nextcloud php /var/www/html/cron.php` to host system user crontab (`sudo crontab -e`)
