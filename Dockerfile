FROM ghcr.io/pelican-eggs/steamcmd:debian

ENV ENABLE_MODS=0

USER root
RUN export DEBIAN_FRONTEND=noninteractive \
	&& apt-get update \
	&& apt-get dist-upgrade \
	&& apt-get install --no-install-recommends -y jq \
	&& rm -fR /var/lib/apt/lists/*

USER container
ADD entrypoint.sh install-mods.sh /
RUN chmod 0755 /entrypoint.sh /install-mods.sh
