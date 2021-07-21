#!/bin/bash -ex
BUILD_NAME=${GITHUB_RUN_ID:=local-$(date +%s)}

echo "Build name: $BUILD_NAME"
echo
echo "Running full test suite 😺"

./gradlew test
