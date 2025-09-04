Class {
	#name : 'NTCommandLineHandler',
	#superclass : 'CommandLineHandler',
	#category : 'TheNoteTaker-Release',
	#package : 'TheNoteTaker-Release'
}

{ #category : 'accessing' }
NTCommandLineHandler class >> commandName [

	^ 'noteTaker'
]

{ #category : 'accessing' }
NTCommandLineHandler class >> description [

	^ 'A Note Taker application developed in Pharo'
]

{ #category : 'building' }
NTCommandLineHandler class >> generateApplication [

	<script: 'self generateApplication'>
	AppGeneratorOSXGenerator new
		properties: {
				(#AppName -> 'NoteTaker').
				(#InfoString -> 'A note taking application written in Pharo').
				(#BundleIdentifier -> 'org.pharo.notetaker').
				(#ShortVersion -> '1.0.0').
				(#IconSetFile -> self iconFile).
				(#DisplayName -> 'Note Taker').
				(#CommandLineHandler -> 'noteTaker').
				(#CompanyName -> 'INRIA').
				(#VMType -> 'Spur') } asDictionary;
		outputDirectory: FileLocator workingDirectory / 'build';
		generate
]

{ #category : 'building' }
NTCommandLineHandler class >> iconFile [
	"We use workingDirectory for the build in github be able to find the logo icons.
	In reality, the icons are at location:
	^ (IceRepository repositoryNamed: 'the-note-taker') location / 'ressources' / 'logo.icns'"
	
	^ FileLocator workingDirectory / 'ressources' / 'logo.icns'	
]

{ #category : 'activation' }
NTCommandLineHandler >> activate [

	AppGeneratorSupport errorHandler:
		AppGeneratorSDLMessageErrorHandler new.
	OSWindowDriver current startUp: true.

	OSPlatform current isMacOSX
		ifTrue: [
				| main |
				main := CocoaMenu new.
				main
					title: 'MainMenu';
					"Only informative"addSubmenu: 'Application' with: [ :m |
							m
								addItemWithTitle: 'Quit'
								action: [ Smalltalk snapshot: false andQuit: true ]
								shortcut: 'q'];
					addSubmenu: 'Help' with: [ :m |
						m
							addItemWithTitle: 'Show Help'
							action: [ self inform: 'Help' ]
							shortcut: '' ].
				main setAsMainMenu.
				NTSpApplication new startFullScreen ]
		ifFalse: [ self inform: 'Not OSX' ]
]
