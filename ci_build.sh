#!/usr/bin/env bash
set -e
[ -n "${DEBUG}" ] && set -x

GRADLE_IMAGE="quay.io/ukhomeofficedigital/gradle:v2.13.6"
GIT_COMMIT=${GIT_COMMIT:-$(git rev-parse --short HEAD)}
GIT_COMMIT=${GIT_COMMIT:0:7}
VERSION=$(grep ^version build.gradle | cut -d= -f 2 | tr -d ' ' | sed -e "s|'||g")

build() {

  MOUNT="${PWD}:/code"
  # Mount in the local gradle cache into the docker container
  #[ -d "${HOME}/.gradle/caches" ] && MOUNT="${MOUNT} -v ${HOME}/.gradle/caches:/root/.gradle/caches"

  # Mount in local maven repository into the docker container
  #[ -d "${HOME}/.m2/repository" ] && MOUNT="${MOUNT} -v ${HOME}/.m2/repository:/root/.m2/repository"

  # Mount in local gradle user directory
  #[ -d "${HOME}/.gradle" ] && MOUNT="${MOUNT} -v ${HOME}/.gradle:/root/.gradle"

  ENV_OPTS="GIT_COMMIT=${GIT_COMMIT} -e VERSION=${VERSION} -e ARTIFACTORY_USER=${ARTIFACTORY_USER} -e ARTIFACTORY_PASS=${ARTIFACTORY_PASS}"
  [ -n "${BUILD_NUMBER}" ] && ENV_OPTS="BUILD_NUMBER=${BUILD_NUMBER} -e ${ENV_OPTS}"

  docker run -e ${ENV_OPTS} -v ${MOUNT} "${GRADLE_IMAGE}" "${@}"
}


function dockerCredentials() {
    DOCKER_CREDS_DIR='/root/.docker'
    SOURCE_CREDS='/root/.secrets/config.json'

    if [[ -n ${AWS_REGION} ]] && [[ -d /root/.aws ]] && [[ -n ${JENKINS_OPTS} ]] && [[ -n ${JENKINS_HOME_S3_BUCKET_NAME} ]]
    then
        echo "running ${FUNCNAME[0]}"
        echo "setting docker credentials"
        if [[ ! -d ${DOCKER_CREDS_DIR} ]];
        then
            mkdir ${DOCKER_CREDS_DIR}
            cp ${SOURCE_CREDS} ${DOCKER_CREDS_DIR}/config.json
        else
            cp ${SOURCE_CREDS} ${DOCKER_CREDS_DIR}/config.json
        fi
    else
        echo "no credentials setup needed on local laptop/workstation ..."
    fi

}

echo "=== docker credentials setup"
dockerCredentials
echo "=== build function"
build "${@}"

