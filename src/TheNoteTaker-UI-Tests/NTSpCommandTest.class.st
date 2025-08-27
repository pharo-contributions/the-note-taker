Class {
	#name : 'NTSpCommandTest',
	#superclass : 'NTSpTestCase',
	#instVars : [
		'indexPresenter',
		'command'
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
	
	indexPresenter := mainPresenter notesIndexPresenter.

	ressources addingNotesAndTagsTo: noteContainer.
	indexPresenter updatePresenter
]
