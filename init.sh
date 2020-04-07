psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOF

	CREATE USER docker WITH PASSWORD 'docker';
	CREATE DATABASE docker OWNER docker;
	GRANT ALL PRIVELEDGES ON DATABASE docker TO docker;
EOF
#	\c docker docker
PGPASSWORD=docker psql -v -d docker -U docker <<-EOF	
	CREATE TABLE prices (
		id UUID PRIMARY KEY,
		price INTEGER,
		transaction_date VARCHAR, -- could try make datetime
		postcode VARCHAR,
		property_type CHAR,
		old_new CHAR, --could map to boolean
		duration VARCHAR, --not sure about variants for this
		poan VARCHAR,
		soan VARCHAR,
		street VARCHAR,
		locality VARCHAR,
		town_city VARCHAR,
		district VARCHAR,
		county VARCHAR,
		ppd_category_type CHAR,
		record_status CHAR
	);

	CREATE TABLE coords (
		id UUID PRIMARY KEY,
		latitude FLOAT,
		longitude FLOAT
	);

	\copy prices FROM '/pp-2019.csv' WITH (FORMAT csv);
	\copy coords FROM '/pp-2019-coords.csv' WITH (FORMAT csv);

	CREATE TABLE coords2 (
		id UUID PRIMARY KEY,
		coord POINT
	);

	INSERT INTO coords2 (id, coord) SELECT id, point(longitude, latitude) FROM coords;
EOF
