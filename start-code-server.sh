#/bin/bash
docker build . \
    --build-arg CACHE_BREAKER=$(date +"%Y-%m-%d") \
    -t cseickel/arch-linux
docker run \
    -v ~:/home/arch \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --network host \
    cseickel/arch-linux
