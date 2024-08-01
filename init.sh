#!/bin/bash
if [ ! -f .env ]; then
    cp -v files/.env.example .env
fi
if [ ! -f secrets/POSTGRES_PASSWORD.secret ]; then
    touch secrets/POSTGRES_PASSWORD.secret
fi
mkdir -p ./data/{db,storage}