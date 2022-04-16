#!/bin/bash
set -x

DB=db-docker-compose.yml
SVC=svc-docker-compose.yml
DB_PROJECT_NM=imgdb
SVC_PROJECT_NM=imgsvc
BASE_IMG_NAME=image-base

export CONFIG_SERVER=http://localhost:9001

function build {
    docker build -t ${BASE_IMG_NAME} -f base/Dockerfile ./base
}

function dc {
    docker-compose -p $2 -f $3 $1
}

function _curl {
curl -s ${CONFIG_SERVER}${1} --header 'Content-Type: text/plain' --data-raw $2
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

function build_jar {
(cd $1 && mvn -Dspring.profiles.active=test clean package)
}

function build_jars {
build_jar ../imagelib-config-server \
&& build_jar ../imagelib-api \
&& build_jar ../imagelib-discovery \
&& rm jars/{api,config-server,discovery}-0.0.1-SNAPSHOT.jar \
&& cp ../imagelib-{config-server,api,discovery}/target/*.jar jars/ \
&& ls -al jars/
}

function encrypt {
_curl "/encrypt" $1
}
function decrypt {
_curl "/decrypt" $1
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
    build_jars)
        build_jars
        ;;
    enc)
        encrypt $2
        ;;
    dec)
        decrypt $2
        ;;
    *)
        echo "Usage: $0 {up|down|reload}"
        exit 1
esac
