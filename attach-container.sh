#!/bin/bash
EXISTING=$(docker container ls -q)
if [[ $EXISTING ]]; then
    docker attach $EXISTING
else
    docker run -it -v arch-linux-volume:/home/arch -v /var/run/docker.sock:/var/run/docker.sock --network host cseickel/arch-linux tmux
    #docker run -it -v arch-linux-volume:/home/arch --network host cseickel/arch-linux tmux
fi

