#!/bin/bash -ex
BUILD_NAME=${GITHUB_RUN_ID:=local-$(date +%s)}

(
  set +x
  echo "Running full test suite 😺"
)

./gradlew test
