FROM postgres:11.7
ENV POSTGRES_USER maintenance_user
ENV POSTGRES_PASSWORD maintenance_password
ENV POSTGRES_DB maintenance_db
# COPY init.sql /docker-entrypoint-initdb.d/
