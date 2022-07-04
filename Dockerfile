FROM debian:stretch-slim AS downloader

ARG SERVER_VER="1436"
ARG SERVER_VER_INC="042"
ARG TMODLOADER_VERSION="v2022.06.96.4"

RUN apt-get update && \
    apt-get install -y unzip curl

RUN curl -L \
        -o /tmp/terrariaServer.zip \
        https://terraria.org/api/download/pc-dedicated-server/terraria-server-${SERVER_VER}.zip && \
    curl -L \
        -o /tmp/tModLoader.zip \
        https://github.com/tModLoader/tModLoader/releases/download/${TMODLOADER_VERSION}/tModLoader.zip && \
    unzip -d /tmp /tmp/terrariaServer.zip && \
    unzip -d /tmp/tModLoader /tmp/tModLoader.zip

FROM debian:stretch-slim AS runner

WORKDIR /terraria

COPY --from=downloader /tmp/${SERVER_VER}/Linux /terraria
COPY --from=downloader /tmp/tModLoader/* /terraria/
COPY ./default-config.txt /default-config.txt


EXPOSE 7777
# USER terraria
ENTRYPOINT ["./tModLoaderServer.bin.x86_64"]
CMD ["-config", "/default-config.txt"]
