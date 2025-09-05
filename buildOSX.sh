#!/bin/bash

set -x
set -e

wget -O -  get.pharo.org/64/130+vm | bash

./pharo Pharo.image --no-default-preferences;
./pharo Pharo.image st scripts/preLoading.st --save --quit;
./pharo Pharo.image metacello install tonel://$GITHUB_WORKSPACE/src BaselineOfTheNoteTaker --groups=Release;
./pharo Pharo.image eval "(IceRepositoryCreator new location: '$GITHUB_WORKSPACE' asFileReference; createRepository) register.";

./pharo Pharo.image eval "NTCommandLineHandler generateApplication";

cd build
chmod +x build.sh
./build.sh
