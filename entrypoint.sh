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

echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bashrc
. ~/.bashrc
mkdir ~/local
mkdir ~/node-latest-install
cd ~/node-latest-install
curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
./configure --prefix=~/local
make install # ok, fine, this step probably takes more than 30 seconds...
curl https://www.npmjs.org/install.sh | sh
npm -v &&


npm install &&

# cd $FIREBASE_PROJECT_PATH

firebase deploy \
    -m "${GITHUB_SHA}" \
    --project ${FIREBASE_PROJECT} \
    --only functions
