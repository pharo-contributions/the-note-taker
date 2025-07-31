Class {
	#name : 'NTSpCommandTest',
	#superclass : 'NTSpTestCase',
	#instVars : [
		'indexPresenter',
		'command',
		'mainPresenter'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'testing' }
NTSpCommandTest class >> isAbstract [ 
	^ self = NTSpCommandTest 
]

{ #category : 'running' }
NTSpCommandTest >> setUp [

	super setUp.

	mainPresenter := NTSpNoteTakerMainUI newApplication: app.
	indexPresenter := mainPresenter notesIndexPresenter.

	indexPresenter model: noteContainer.
	ressources addingNotesAndTagsTo: noteContainer.
	indexPresenter updatePresenter
]
