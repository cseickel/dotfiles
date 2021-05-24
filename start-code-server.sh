#/bin/bash
EXISTING=$(docker container ls | grep code-server | awk '{ print $1}')
if [[ $EXISTING ]]; then
    echo "code-server conatiner is already running, run the following to stop it:"
    echo "docker container stop $EXISTING"
    echo ""
else
    EXISTING=$(docker run -d -v ~/:/home/arch -v /var/run/docker.sock:/var/run/docker.sock --network host --name code-server cseickel/arch-linux)
fi
docker logs --follow $EXISTING

