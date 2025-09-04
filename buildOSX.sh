#!/bin/bash

set -x
set -e

wget -O -  get.pharo.org/64/130+vm | bash
tree
./pharo Pharo.image st scripts/preLoading.st --save --quit;
./pharo Pharo.image metacello install github://$GITHUB_REPOSITORY/src BaselineOfTheNoteTaker --groups=Release;

./pharo Pharo.image eval "NTCommandLineHandler generateApplication";

cd build
chmod +x build.sh
./build.sh
