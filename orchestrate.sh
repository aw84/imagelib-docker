#!/bin/bash
set -x

DB=db-docker-compose.yml
SVC=svc-docker-compose.yml
DB_PROJECT_NM=imgdb
SVC_PROJECT_NM=imgsvc
BASE_IMG_NAME=image-base

function build {
    docker build -t ${BASE_IMG_NAME} -f base/Dockerfile ./base
}

function dc {
    docker-compose -p $2 -f $3 $1
}

function up {
dc "up -d" ${DB_PROJECT_NM} ${DB} \
&& dc "up -d" ${SVC_PROJECT_NM} ${SVC}
}

function down {
dc down ${SVC_PROJECT_NM} ${SVC} \
&& dc down ${DB_PROJECT_NM} ${DB}
}

function rebuild_svc {
dc "down --remove-orphans" ${SVC_PROJECT_NM} ${SVC} \
&& docker image rm ${BASE_IMG_NAME} \
&& build \
&& dc "up -d" ${SVC_PROJECT_NM} ${SVC}
}

function reload_svc {
dc "down --remove-orphans" ${SVC_PROJECT_NM} ${SVC} \
&& dc "up -d" ${SVC_PROJECT_NM} ${SVC}
}

function list_svc {
dc ps ${DB_PROJECT_NM} ${DB} \
&& dc ps ${SVC_PROJECT_NM} ${SVC}
}

case "$1" in
    build)
        build
        ;;
    up)
        up
        ;;
    down)
        down
        ;;
    rebuild)
        rebuild_svc
        ;;
    reload)
        reload_svc
        ;;
    list)
        list_svc
        ;;
    *)
        echo "Usage: $0 {up|down|reload}"
        exit 1
esac
