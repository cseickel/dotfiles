#/bin/bash
if [ ! "$TMUX" ]; then
    EXISTING=$(docker container ls | grep arch-linux-tmux | awk '{ print $1}')
    if [[ $EXISTING ]]; then
        docker attach $EXISTING
    else
        EXISTING=$(docker run --rm -d -it \
            -v /var/run/docker.sock:/var/run/docker.sock \
            -v /home:/home \
            -h $HOSTNAME \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -e DISPLAY=$DISPLAY \
            -h $HOSTNAME \
            -v $HOME/.Xauthority:/home/$USER/.Xauthority \
            --network host \
            --name arch-linux-tmux \
            cseickel/arch-linux \
            tmux)
        docker attach $EXISTING
    fi
fi
