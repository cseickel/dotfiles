#!/bin/bash
EXISTING=$(docker container ls | grep cseickel/arch-linux | awk '{ print $1}')
if [[ $EXISTING ]]; then
    docker attach $EXISTING
else
    docker run -it -v ~:/home/arch -v /var/run/docker.sock:/var/run/docker.sock --network host cseickel/arch-linux tmux
    #docker run -it -v arch-linux-volume:/home/arch --network host cseickel/arch-linux tmux
fi

