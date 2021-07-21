#!/bin/bash -e
BUILD_NAME=${GITHUB_RUN_ID:=local-$(date +%s)}

echo "Installing Launchable CLI..."
pip3 install --user launchable~=1.0 >/dev/null

echo "Verifying connectivity to Launchable..."
launchable verify

echo "Sending changes in build $BUILD_NAME to Launchable..."
launchable record build --name "$BUILD_NAME" --source src=.

echo "Getting a subset of tests to run for $BUILD_NAME from Launchable..."
launchable subset --target 25% --build "$BUILD_NAME" gradle src/test/java >subset.txt

echo "Launchable subset for $BUILD_NAME contents:"
cat subset.txt

echo "Running Launchable subset 😎..."
./gradlew test $(<subset.txt)

function record() {
  echo "Sending test results for build $BUILD_NAME to Launchable..."
  launchable record tests --build "$BUILD_NAME" gradle build/test-results/test
}

trap record EXIT
