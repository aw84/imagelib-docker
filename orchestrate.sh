#!/bin/bash
set -x
eval $(minikube -p minikube docker-env)
DB=db-docker-compose.yml
SVC=svc-docker-compose.yml
DB_PROJECT_NM=imgdb
SVC_PROJECT_NM=imgsvc
BASE_IMG_NAME=image-base

export CONFIG_SERVER=http://localhost:9001

function build {
    docker build -t awpms/${BASE_IMG_NAME} -f base/Dockerfile ./base
}

function dc {
    docker-compose -p $2 -f $3 $1
}

function _curl {
curl -s ${CONFIG_SERVER}${1} --header 'Content-Type: text/plain' --data-raw $2
}
function _curl_get {
curl -s ${CONFIG_SERVER}${1}
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
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
build_jar ../imagelib-config-server \
&& build_jar ../imagelib-api \
&& build_jar ../imagelib-discovery \
&& build_jar ../imagelib-frontend \
&& rm jars/{api,config-server,discovery,frontend}-0.0.1-SNAPSHOT.jar \
&& cp -v ../imagelib-{config-server,api,discovery,frontend}/target/*.jar jars/ \
&& ls -al jars/
}

function encrypt {
_curl "/encrypt" $1
}
function decrypt {
_curl "/decrypt" $1
}
function get_config {
_curl_get $1
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
    get_config)
        get_config $2
        ;;
    *)
        echo "Usage: $0 {up|down|reload}"
        exit 1
esac
