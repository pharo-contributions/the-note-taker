#!/bin/bash

set -x
set -e

wget -O -  get.pharo.org/64/130+vm | bash
./pharo Pharo.image save TNT

if [ ! -z "$GITHUB_WORKSPACE" ] 
then
	./pharo TNT.image eval --save "Metacello new 
	    baseline:'TheNoteTaker'; 
	    repository: 'gitlocal://$GITHUB_WORKSPACE/src';
		onUpgradeUseLoaded;
		onConflictUseLoaded;
	    load"
else
	./pharo TNT.image eval --save "Metacello new
	    baseline:'TheNoteTaker';
	    repository: 'github://moufort/the-note-taker/src';
		onUpgradeUseLoaded;
		onConflictUseLoaded;
	    load"
fi

./pharo TNT.image eval "NTSpApplication generateOSXPackage"

cd build
chmod +x build.sh
./build.sh
