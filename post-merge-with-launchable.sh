#!/bin/bash -e
BUILD_NAME=${GITHUB_RUN_ID:=local-$(date +%s)}

echo "Installing the Launchable CLI..."
pip3 install --user launchable~=1.0 >/dev/null

echo "Verifying connectivity to Launchable..."
launchable verify

echo "Sending changes in build $BUILD_NAME to Launchable..."
launchable record build --name "$BUILD_NAME" --source src=.

echo "Running full test suite 😺..."
./gradlew test

function record() {
  echo "Sending test results for build $BUILD_NAME to Launchable..."
  launchable record tests --build "$BUILD_NAME" gradle build/test-results/test
}

trap record EXIT
