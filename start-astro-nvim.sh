#/bin/bash
EXISTING=$(docker container ls | grep arch-linux-tmux-astro | awk '{ print $1}')
if [[ $EXISTING ]]; then
    docker attach $EXISTING
else
    EXISTING=$(docker run --rm -d -it \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ~/:/home/${USER}/astronvim \
        -e HOME="/home/${USER}/astronvim" \
        --network host \
        --name arch-linux-tmux-astro \
        cseickel/arch-linux \
        tmux)
    docker attach $EXISTING
fi

