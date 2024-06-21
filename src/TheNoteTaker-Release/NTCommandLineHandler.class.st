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
	
	(self environment at: #AppGeneratorOSXGenerator) new
		properties: { 
        #AppName -> 'NoteTaker' .
        #InfoString -> 'A note taking application written in Pharo' .
        #BundleIdentifier -> 'org.pharo.notetaker' .
        #ShortVersion -> '1.0.0' .
        #DisplayName -> 'Note Taker' .
        #CommandLineHandler -> 'noteTaker' .
        #CompanyName -> 'INRIA' } asDictionary;
		outputDirectory: FileLocator workingDirectory / 'build';
		generate.
]

{ #category : 'activation' }
NTCommandLineHandler >> activate [

	AppGeneratorSupport errorHandler: AppGeneratorSDLMessageErrorHandler new.
	OSWindowDriver current startUp: true.

	OSPlatform current isMacOSX
		ifTrue: [ | main |
			main := CocoaMenu new.
			main	title: 'MainMenu'; "Only informative"
				addSubmenu: 'Application' with: [ :m |
					m
						addItemWithTitle: 'Quit'
						action: [ Smalltalk snapshot: false andQuit: true ]
						shortcut: 'q' ];
				addSubmenu: 'Help' with: [ :m |
					m
						addItemWithTitle: 'Show Help'
						action: [ self inform: 'Help' ]
						shortcut: '' ].
			main setAsMainMenu.
			
			NTSpApplication new start ]
		ifFalse: [ self inform: 'Not OSX' ].


]
