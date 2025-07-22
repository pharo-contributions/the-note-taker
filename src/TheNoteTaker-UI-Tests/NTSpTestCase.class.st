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
	previousNotesLocation := settings noteLocation.

	memoryFS := FileSystem memory.
	settings noteLocation: memoryFS workingDirectory.

	app := NTSpApplication new.
	noteContainer := app noteTakerContainer.
	ressources := NTUITestResource new
]

{ #category : 'running' }
NTSpTestCase >> tearDown [

	settings noteLocation: previousNotesLocation.
	app closeAllWindows.

	super tearDown
]
