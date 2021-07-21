#!/bin/bash -ex
BUILD_NAME=${GITHUB_RUN_ID:=local-$(date +%s)}

pip3 install --user launchable~=1.0

launchable verify

launchable record build --name "$BUILD_NAME" --source src=.

launchable subset --target 25% --build "$BUILD_NAME" gradle src/test/java >subset.txt

cat subset.txt

function record() {
  launchable record tests --build "$BUILD_NAME" gradle build/test-results/test
}

trap record EXIT

echo "Build name: $BUILD_NAME"
echo
echo "Running Launchable subset 😎"

./gradlew test $(<subset.txt)
