# MASSA Blockchain Node - Docker Image

The MASSA blockchain node ( https://massa.net ) can be launched with a single command using the Docker containerization technology.


**Important!** Before proceeding further, make sure that Docker is installed on your server.
More details here: https://www.docker.com/get-started/


Link to Github repository: https://github.com/dex2code/massa-docker

Link to Docker repository: https://hub.docker.com/r/dex2build/massa-node

# Simple one-line launch:

## Starting the node with `docker run`
    docker network create --driver="bridge" --ipv6 "massa-network" && \
    docker container run \
      --detach \
      --env=MASSA_PASS="" \
      --env=MASSA_ADDRESS="$(curl ifconfig.me)" \
      --hostname="massa" \
      --init \
      --name="massa_node" \
      --network="massa-network" \
      --publish="31244:31244" \
      --publish="31245:31245" \
      --publish="33035:33035" \
      --publish="33037:33037" \
      --restart="unless-stopped" \
      dex2build/massa-node:latest

`MASSA_PASS` - Specify your own password or leave this variable empty so that the container generates and remembers a random password

`MASSA_ADDRESS` - Specify your external address so that your node is a full member of the network

## Starting the node with `docker compose`
    cd ~ && mkdir massa-docker && cd massa-docker && \
    wget https://raw.githubusercontent.com/dex2code/massa-docker/refs/heads/main/docker-compose.yml

! Important - please modify environment variables `MASSA_PASS` and `MASSA_ADDRESS` in `docker-compose.yml` according to your parameters before start the following command

    docker compose up -d


## Using the MASSA client to configure the node
    docker container exec -ti massa_node massa-client.sh

## Access to the host shell
    docker container exec -ti massa_node bash

## Watch node logs
    docker container logs -f massa_node


# Expert mode:

### Clone repository
    cd ~ && \
    git clone https://github.com/dex2code/massa-docker.git ./massa-docker && \
    cd ./massa-docker

### Build image
    docker buildx build \
      --no-cache \
      --progress="plain" \
      --tag="massa-node:latest" \
      .

### Create a separated network
    docker network create --driver="bridge" --ipv6 "massa-network"

### Create container
    docker container create \
      --env=MASSA_PASS="" \
      --env=MASSA_ADDRESS="$(curl ifconfig.me)" \
      --hostname="massa" \
      --init \
      --name="massa_node" \
      --network="massa-network" \
      --publish="31244:31244" \
      --publish="31245:31245" \
      --publish="33035:33035" \
      --publish="33037:33037" \
      --restart="unless-stopped" \
      massa-node:latest

`MASSA_PASS` - Specify your own password or leave this variable empty so that the container generates and remembers a random password

`MASSA_ADDRESS` - Specify your external address so that your node is a full member of the network


### Start container
    docker container start massa_node

### Stop container
    docker container stop massa_node

### Remove container
    docker container rm massa_node

### Remove image
    docker image rm massa-node:latest

### Remove network
    docker network rm massa-network
