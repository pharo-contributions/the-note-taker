[![license-badge](https://img.shields.io/badge/license-MIT-blue.svg)](https://img.shields.io/badge/license-MIT-blue.svg)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

# Table of Contents

- [Description](#description)
- [Installation](#installation)
  - [Baseline String](#baseline-string)
- [Usage](#usage)
- [Screenshot](#screenshot)
- [Implementation notes](#implementation-notes)
  - [Generate a Release](#generate-a-release) 
- [Contribute](#contribute)
  - [Version management](#version-management)
- [License](#license)

# Description

# Installation

```smalltalk
#( 'Microdown' ) do: [ :name |
		(IceRepository repositoryNamed: name)
			ifNil: [ self inform: 'Project not found: ' , name ]
			ifNotNil: [ :found |
				found
					unload;
					forget ] ].
	Smalltalk globals 
			at: #BaselineOfMicrodown 
			ifPresent: [ :c | c removeFromSystem ].		

Metacello new	
	baseline: 'TheNoteTaker';	
	repository: 'github://pharo-contributions/the-note-taker/src';	
	load.
```


# Usage

- If you install the application from an executable, the UI will be already displayed.
- If you install the application through the Metacello manager
	- You can open the application through the UI: **Library** -> **The Note Taker**
	- Or you can open the application with the following expression:

```smalltalk
NTSpApplication new start.
```

# Screenshot

<img width="915" alt="Screenshot 2024-02-08 at 20 30 03" src="https://github.com/hernanmd/the-note-taker/assets/4825959/707d20ef-b67c-48b3-8e56-4092318a7746">

# Implementation notes

## Generate a Release

### MacOS

To generate a macOS installer (.dmg) and executable file (.app) you can evaluate the following one-liner in your terminal:

```bash
wget -O- get.pharo.org/64/130+vm | bash; ./pharo Pharo.image metacello install github://hernanmd/the-note-taker/src BaselineOfTheNoteTaker --groups=Release; ./pharo Pharo.image eval "NTCommandLineHandler generateApplication"; chmod 755 build/build.sh; cd build; ./build.sh; open NoteTaker.app
```

### GNU/Linux

Work in Progress

# Contribute

**Working on your first Pull Request?** You can learn how from this *free* series [How to Contribute to an Open Source Project on GitHub](https://egghead.io/series/how-to-contribute-to-an-open-source-project-on-github)

If you have discovered a bug or have a feature suggestion, feel free to create an issue on Github.
If you have any suggestions for how this package could be improved, please get in touch or suggest an improvement using the GitHub issues page.
If you'd like to make some changes yourself, see the following:    

  - Fork this repository to your own GitHub account and then clone it to your local device
  - Do some modifications
  - Test.
  - Add <your GitHub username> to add yourself as author below.
  - Finally, submit a pull request with your changes!
  - This project follows the [all-contributors specification](https://github.com/kentcdodds/all-contributors). Contributions of any kind are welcome!

## Version management 

This project use semantic versioning to define the releases. This means that each stable release of the project will be assigned a version number of the form `vX.Y.Z`. 

- **X** defines the major version number
- **Y** defines the minor version number 
- **Z** defines the patch version number

When a release contains only bug fixes, the patch number increases. When the release contains new features that are backward compatible, the minor version increases. When the release contains breaking changes, the major version increases. 

Thus, it should be safe to depend on a fixed major version and moving minor version of this project.

# License
	
This software is licensed under the MIT License.

Copyright Hernán Morales Durand, '2024'.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Authors

Hernán Morales Durand
