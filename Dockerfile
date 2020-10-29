FROM ubuntu:20.04
WORKDIR /root
COPY scripts/ .
RUN ./setup.sh && rm setup.sh
EXPOSE 1194/udp
ENTRYPOINT ["/bin/bash","./entrypoint.sh"]
