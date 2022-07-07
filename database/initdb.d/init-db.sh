#!/bin/bash
set -e
set -x
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER imgdev WITH PASSWORD 'imgdev';
	CREATE DATABASE imgdevdb;
	GRANT ALL PRIVILEGES ON DATABASE imgdevdb TO imgdev;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname imgdevdb <<-EOSQL
	CREATE EXTENSION pgcrypto;
EOSQL

psql -v ON_ERROR_STOP=1 --username imgdev --dbname imgdevdb <<-EOSQL
	CREATE TYPE image_quality AS ENUM ('original', 'big', 'small', 'tiny');
create table image (
	image_id uuid primary key default gen_random_uuid(),
	cname text
);
create table storage (
	storage_id uuid primary key default gen_random_uuid(),
	image_id uuid not null references image (image_id) on delete cascade,
	quality IMAGE_QUALITY,
	hash text,
	protocol text, /*file://, http://, s3:// */
	host text,
	relative_path text
);
EOSQL