#/bin/bash
TODAY=$(date +"%Y-%m-%d")
docker build . \
    --build-arg CACHE_BREAKER=$TODAY \
    -t cseickel/arch-linux
docker tag cseickel/arch-linux "cseickel/arch-linux:$TODAY"
