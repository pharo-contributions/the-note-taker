Class {
	#name : 'NTSpTestCase',
	#superclass : 'TestCase',
	#instVars : [
		'app',
		'noteContainer',
		'previousNotesLocation',
		'settings',
		'memoryFS',
		'ressources'
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

	settings := NTSettings.

	memoryFS := FileSystem memory.

	app := NTSpApplication new.
	app currentFolder: memoryFS workingDirectory.
	noteContainer := app noteTakerContainer.
	ressources := NTUITestResource new
]

{ #category : 'nil' }
NTSpTestCase >> tearDown [

	app ifNotNil: [ app closeAllWindows ].

	super tearDown
]
