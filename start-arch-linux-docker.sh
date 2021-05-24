#/bin/bash
EXISTING=$(docker container ls | grep arch-linux-tmux | awk '{ print $1}')
if [[ $EXISTING ]]; then
    docker attach $EXISTING
else
    EXISTING=$(docker run -d -it -v ~/:/home/arch -v /var/run/docker.sock:/var/run/docker.sock --network host --name arch-linux-tmux cseickel/arch-linux tmux)
    docker attach $EXISTING
fi

