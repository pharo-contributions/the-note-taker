#!/bin/bash

set -x
set -e

wget -O -  get.pharo.org/64/130+vm | bash

./pharo Pharo.image --no-default-preferences st scripts/preLoading.st --save --quit;
./pharo Pharo.image --no-default-preferences metacello install tonel://$GITHUB_WORKSPACE/src BaselineOfTheNoteTaker --groups=Release;
./pharo Pharo.image --no-default-preferences eval --save "(IceRepositoryCreator new location: '$GITHUB_WORKSPACE' asFileReference; createRepository) name: 'the-note-taker'; register.";

./pharo Pharo.image --no-default-preferences eval "NTCommandLineHandler generateApplication";

cd build
chmod +x build.sh
./build.sh
