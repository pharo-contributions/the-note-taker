#!/bin/bash

set -x
set -e

wget -O -  get.pharo.org/64/130+vm | bash

./pharo Pharo.image st scripts/preLoading.st --save --quit;
./pharo Pharo.image metacello install github://pharo-contributions/the-note-taker/src BaselineOfTheNoteTaker --groups=Release;

./pharo Pharo.image eval "NTCommandLineHandler generateApplication";

cd build
chmod +x build.sh
./build.sh
