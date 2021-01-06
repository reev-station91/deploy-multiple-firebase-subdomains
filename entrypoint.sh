#!/bin/sh

if [ -z "${FIREBASE_TOKEN}" ]; then
    echo "FIREBASE_TOKEN is missing"
    exit 1
fi

if [ -z "${FIREBASE_PROJECT}" ]; then
    echo "FIREBASE_PROJECT is missing"
    exit 1
fi

if [ -z "${TARGET_BRANCH}" ]; then
    TARGET_BRANCH="master"
fi

if [ "${GITHUB_REF}" != "refs/heads/${TARGET_BRANCH}" ]; then
    echo "Current branch: ${GITHUB_REF}"
    echo "Aborting deployment"
    exit 1
fi

# Go to path with firebase configuration
ls 

cd ./api/api-server 

ENV NODE_VERSION=12.6.0
RUN apt install -y curl
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version &&


npm install &&

# cd $FIREBASE_PROJECT_PATH

firebase deploy \
    -m "${GITHUB_SHA}" \
    --project ${FIREBASE_PROJECT} \
    --only functions
