#!/bin/bash
if [ ! -f .env ]; then
    cp -v files/.env.example .env
fi
if [ ! -f secrets/POSTGRES_PASSWORD.secret ]; then
    mkdir -p ./secrets
    touch secrets/POSTGRES_PASSWORD.secret
fi