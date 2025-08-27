Class {
	#name : 'NTSpTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'app',
		'noteContainer',
		'previousNotesLocation',
		'settings',
		'memoryFS',
		'ressources',
		'mainPresenter'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'testing' }
NTSpTestCase class >> shouldInheritSelectors [

	^ true
]

{ #category : 'running' }
NTSpTestCase >> setUp [

	super setUp.

	memoryFS := FileSystem memory.

	app := NTSpApplication new.
	app currentFolder: memoryFS workingDirectory.
	mainPresenter := app mainPresenter.
	noteContainer := app noteTakerContainer.
	ressources := NTTestResource new.
	ressources useFolder: memoryFS
]

{ #category : 'nil' }
NTSpTestCase >> tearDown [

	app ifNotNil: [ app closeAllWindows ].

	super tearDown
]
