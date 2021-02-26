#/bin/bash
docker run -it \
    -v arch-linux-volume:/home/arch \
    -v /var/run/docker.sock:/var/run/docker.sock \
    cseickel/arch-linux tmux
