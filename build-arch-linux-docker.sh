#/bin/bash

TODAY=$(date +"%Y-%m-%d")
docker build . --no-cache -t cseickel/arch-linux && \
#docker build . -t cseickel/arch-linux && \
docker tag cseickel/arch-linux "cseickel/arch-linux:$TODAY" && \
docker push cseickel/arch-linux -a
