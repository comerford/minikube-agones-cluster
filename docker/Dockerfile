FROM ubuntu:latest

RUN useradd --create-home --shell /bin/bash gameserver
RUN apt-get update && apt-get upgrade -y 

EXPOSE 26000/udp

COPY --chown=gameserver:gameserver gs-folder /home/gameserver/

USER gameserver
WORKDIR /home/gameserver/gs-folder

RUN mkdir -p /home/gameserver/gs-folder/LinuxServer/FirstPersonShooter/Saved/Config/LinuxServer
RUN echo "[/Script/Agones.AgonesComponent]" >> /home/gameserver/gs-folder/LinuxServer/FirstPersonShooter/Saved/Config/LinuxServer/Game.ini
RUN echo "HealthRateSeconds=5" >> /home/gameserver/gs-folder//LinuxServer/FirstPersonShooter/Saved/Config/LinuxServer/Game.ini
RUN chmod +x ./rungameserver.sh

ENTRYPOINT ./rungameserver.sh ; uploadcrashedlogstos3.sh