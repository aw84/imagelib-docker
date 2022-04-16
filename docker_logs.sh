#!/bin/bash
# set -x

docker ps -a --filter "name=imgsvc*" --format "{{.Names}}" | while read SVC_NAME;do
echo "----------===========<<<<<<<< [ ${SVC_NAME} ] >>>>>>>>----------==========="
docker logs ${SVC_NAME} | tail -n ${1-5}
done