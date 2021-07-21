#!/bin/bash -ex

pip3 install --user launchable~=1.0
launchable verify

./gradlew test
