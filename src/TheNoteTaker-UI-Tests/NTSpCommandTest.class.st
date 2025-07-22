Class {
	#name : 'NTSpCommandTest',
	#superclass : 'NTSpTestCase',
	#instVars : [
		'indexPresenter'
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

	indexPresenter := NTSpNoteIndexPresenter newApplication: app.

	indexPresenter model: noteContainer.
	ressources generateNoteAndTagsTo: noteContainer.
	indexPresenter updatePresenter
]
