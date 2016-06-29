docker rm `docker ps --no-trunc -aq`
docker rmi $(docker images | grep "^dev-" | awk "{print $3}")
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
sudo rm -rf /hyperledger/db/*
sudo rm -rf /hyperledger/production/*
