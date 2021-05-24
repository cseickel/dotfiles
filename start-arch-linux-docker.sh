#/bin/bash
EXISTING=$(docker container ls | grep arch-linux-tmux | awk '{ print $1}')
if [[ $EXISTING ]]; then
    docker attach $EXISTING
else
    docker build . \
        --build-arg CACHE_BREAKER=$(date +"%Y-%m-%d") \
        -t cseickel/arch-linux
    EXISTING=$(docker run -d -it -v ~/:/home/arch -v /var/run/docker.sock:/var/run/docker.sock --network host --name arch-linux-tmux cseickel/arch-linux tmux)
    docker attach $EXISTING
fi

