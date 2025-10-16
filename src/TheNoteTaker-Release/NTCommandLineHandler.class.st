"
I'm the class with speficication for generate the executable application.

In my instance side, i have the method activate, where i define the application toolbar for each OS.$

In my class side, I have the propertys of the executable
"
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
				(#CompanyName -> 'INRIA') } asDictionary;
		outputDirectory: FileLocator workingDirectory / 'build';
		addExternalFile: self iconPng;
		generate
]

{ #category : 'building' }
NTCommandLineHandler class >> iconFile [

	^ (IceRepository repositoryNamed: 'the-note-taker') location / 'ressources' / 'logo.icns'

]

{ #category : 'building' }
NTCommandLineHandler class >> iconForm [

	^ ImageReadWriter formFromFileNamed:
		  FileLocator imageDirectory / 'logo.png'
]

{ #category : 'building' }
NTCommandLineHandler class >> iconPng [

	^ (IceRepository repositoryNamed: 'the-note-taker') location / 'ressources' / 'logo.png'
]

{ #category : 'activation' }
NTCommandLineHandler >> activate [
	
	"We terminate the UI process if there is no around"
	MorphicUIManager uiProcess ifNotNil: [:aProcess | aProcess terminate].
	
	AppGeneratorSupport errorHandler: AppGeneratorSDLMessageErrorHandler new.

	AppGeneratorSupport windowTitle: 'The Note Taker'.
	"We set it to nothing, to avoid the default world to set the image as 
	a document associated with the window in OSX. You can do that if you wish:
	
	https://developer.apple.com/documentation/appkit/nswindow/settitlewithrepresentedfilename(_:)?language=objc
	"
	AppGeneratorSupport whenWorldWindowTitleChangedDo: [ :driver :osWindw | "We do nothing" ].
	
	
	AppGeneratorSupport worldIcon: self class iconForm.

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
		ifFalse: [ self inform: 'Not OSX' ].
		
		"We open the world forcing the OSWorldRenderer. As we are opening in headless, to control the flow"
		
		World worldState doFullRepaint.
		World worldState worldRenderer: (OSWorldRenderer forWorld: World).

		MorphicUIManager new spawnNewProcess.
		
]
