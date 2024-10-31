#!/bin/bash -e -x

# store the directory information to allow the script to be executed from anywhere
GOLANG_DIR=$(cd `dirname $0` && pwd)
PROJECT_ROOT_DIR=$(dirname "$GOLANG_DIR")

# check to see if there is a leftover docker image with this tag to clean up
docker rmi -f gtfs-golang
# build and tag the docker image
docker build --no-cache -t gtfs-golang -f $GOLANG_DIR/Dockerfile $PROJECT_ROOT_DIR
# run the docker image as a named container running as a daemon (-d)
docker run --name gtfs-golang-container -d gtfs-golang
docker exec -i gtfs-golang-container bash -c "protoc --go_out=./ --go_opt=Mgtfs-realtime.proto=./gtfs --proto_path=.. gtfs-realtime.proto && go test ./..."
# copy the file from the named container running as a daemon onto the host machine
docker cp gtfs-golang-container:/lib/gtfs/gtfs-realtime.pb.go $GOLANG_DIR/gtfs/gtfs-realtime.pb.go
# delete the named container
docker rm -f gtfs-golang-container
