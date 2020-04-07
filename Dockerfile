FROM postgres:latest
COPY ./init.sh /docker-entrypoint-initdb.d/init.sh
COPY ./pp-2019.csv /pp-2019.csv
COPY ./pp-2019-coords.csv /pp-2019-coords.csv
#COPY ./init.sh /init.sh
#ENV POSTGRES_USER docker
#ENV POSTGRES_PASSWORD docker
#ENV POSTGRES_DB docker
#RUN ./init.sh
# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
#RUN ls /etc/postgresql
#RUN echo "host all  all    0.0.0.0/0  md5" >> pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
#RUN echo "listen_addresses='*'" >> postgresql.conf

#EXPOSE 5432
