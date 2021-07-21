#!/bin/bash -ex
BUILD_NAME=${GITHUB_RUN_ID:=local-$(date +%s)}

(
  set +x
  echo "Not running any tests because the suite takes too long 😿"
)
