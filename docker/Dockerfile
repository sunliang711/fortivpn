FROM ubuntu:20.04
RUN apt-get update && apt-get install -y openfortivpn expect tmux

# test
# TODO: delete the following line
RUN apt-get install python3 ssh -y

COPY entrypoint.sh /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]

