Class {
	#name : 'NTCommandLineHandler',
	#superclass : 'CommandLineHandler',
	#category : 'TheNoteTaker-UI',
	#package : 'TheNoteTaker-UI'
}

{ #category : 'accessing' }
NTCommandLineHandler class >> commandName [

	^ 'TheNoteTaker'
]

{ #category : 'activation' }
NTCommandLineHandler >> activate [

	OSWindowDriver current startUp: true.
	AppGeneratorSupport errorHandler: AppGeneratorSDLMessageErrorHandler new.

	OSPlatform current isMacOSX
		ifTrue: [ | main |
			main := CocoaMenu new.
			main	title: 'MainMenu'; "Only informative"
				addSubmenu: 'Application' with: [ :m |
					m
						addItemWithTitle: 'Quit'
						action: [ Smalltalk snapshot: false andQuit: true ]
						shortcut: 'q' ].
 			
			main
				addSubmenu: 'Help' with: [ :m |
					m
						addItemWithTitle: 'Show Help'
						action: [  ]
						shortcut: '' ].
			main setAsMainMenu.
			NTDeploymentScript developmentEnvironmentEnabled: false.
			
			] ifFalse: [ ]
]
