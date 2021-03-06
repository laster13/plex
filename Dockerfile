FROM plexinc/pms-docker:public

ENTRYPOINT ["/init"]

ENV \
  PLEX_AUTOSCAN_CONFIG=/config/plex_autoscan/config.json \
  PLEX_AUTOSCAN_QUEUEFILE=/config/plex_autoscan/queue.db \
  PLEX_AUTOSCAN_LOGFILE=/config/plex_autoscan/plex_autoscan.log \
  USE_DOCKER=false \
  USE_SUDO=false

LABEL Description="Plex Plexdrive Rclone Plex_autoscan Plex_dupefinder" \
      tags="latest" \
      maintainer="laster13 <https://github.com/laster13>" \
      Plex_autoscan="https://github.com/l3uddz/plex_autoscan" \
      Plex_dupefinder="https://github.com/l3uddz/plex_dupefinder" \
      Plexdrive-5.0.0="https://github.com/dweidenfeld/plexdrive"

RUN \
  # Install dependencies
  apt-get update && \
  apt-get full-upgrade -y && \
  apt-get install --no-install-recommends -y \
    git \
    lsof \
    cron \
    python-pip \
    python-dev \
    python3-pip \
    python3.5-dev \
    unzip \
    man.db \
    wget \
    python3-setuptools \
    g++ && \
  # Get plex_autoscan and plex_dupefinder
  git clone --depth 1 --single-branch https://github.com/l3uddz/plex_autoscan.git /plex_autoscan && \
  git clone --depth 1 --single-branch https://github.com/l3uddz/plex_dupefinder.git && \
  # Install/update pip and requirements for plex_autoscan
  pip install --no-cache-dir --upgrade pip setuptools wheel && \
  # PIP upgrade bug https://github.com/pypa/pip/issues/5221
  hash -r pip && \
  # install unionfs_cleaner && plex_dupefinder with python3
  pip3 install --no-cache-dir --upgrade -r /plex_dupefinder/requirements.txt && \
  # Plex_autoscan only works with python2.7
  pip install --no-cache-dir --upgrade -r /plex_autoscan/requirements.txt && \
  # Remove dependencies
  apt-get purge -y --auto-remove \
    python3.5-dev \
    python-dev \
    unzip \
    man.db \
    python3-setuptools \
    g++ && \
  # Clean apt cache
  apt-get clean all && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

COPY root/ /

RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
