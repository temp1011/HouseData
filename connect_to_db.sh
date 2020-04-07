#https://stackoverflow.com/questions/58461178/how-to-fix-error-column-c-relhasoids-does-not-exist-in-postgres
sudo docker exec -it ptest psql -h localhost -p 5432 -d docker -U docker --password
