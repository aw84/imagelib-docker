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
