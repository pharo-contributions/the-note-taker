Class {
	#name : 'NTSpCommandTest',
	#superclass : 'NTSpApplicationTest',
	#instVars : [
		'indexPresenter'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpCommandTest >> setUp [

	super setUp.

	indexPresenter := NTSpNoteIndexPresenter newApplication: app.

	indexPresenter model: noteContainer.
	ressources generateNoteAndTagsTo: noteContainer.
	indexPresenter updatePresenter
]
