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

ARG SERVER_VER="1436"
ARG UID="999"

ENV INSTALL_LOC="/terraria"
ENV WORLDS_LOC="/worlds"
ENV MODS_LOC="/mods"
ENV LOGS_LOC="/logs"

ENV TERRARIA_DATA="/root/.local/share/Terraria/ModLoader"

COPY --from=downloader /tmp/${SERVER_VER}/Linux ${INSTALL_LOC}
COPY --from=downloader /tmp/tModLoader/* ${INSTALL_LOC}/
COPY ./*config.txt /*config.txt

RUN chmod u+x ${INSTALL_LOC}/* && \
    mkdir -p ${TERRARIA_DATA} ${LOGS_LOC} && \
    ln -s ${WORLDS_LOC} ${TERRARIA_DATA}/Worlds && \
    ln -s ${MODS_LOC} ${TERRARIA_DATA}/Mods && \
    ln -s ${LOGS_LOC} ${TERRARIA_DATA}/Logs
    # chown -R terraria:terraria ${TERRARIA_DATA}

# TODO: fix; readd chowns to COPYs, adjust TERRARIA_DATA etc
# RUN useradd -m -u ${UID} -s /bin/false terraria

VOLUME ${WORLDS_LOC} ${MODS_LOC}
WORKDIR ${INSTALL_LOC}
EXPOSE 7777
ENTRYPOINT ["/terraria/*tModLoaderServer.sh"]
