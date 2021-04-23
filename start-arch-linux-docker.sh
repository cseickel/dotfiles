#/bin/bash
docker build . \
    --build-arg CACHE_BREAKER=$(date +"%Y-%m-%d") \
    -t cseickel/arch-linux
docker run -it \
    -v arch-linux-volume:/home/arch \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 127.0.0.1:8080:8080 -p 127.0.0.1:8180:8180 \
    -p 127.0.0.1:5002:5002 -p 127.0.0.1:7777:7777 \
    cseickel/arch-linux tmux
