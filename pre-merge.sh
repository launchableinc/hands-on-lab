#!/bin/bash -ex
BUILD_NAME=${GITHUB_RUN_ID:=local-$(date +%s)}

echo "Build name: $BUILD_NAME"
echo
echo "Not running any tests because the suite takes too long 😿"
