Class {
	#name : 'NTSpTagSelectionDialogTest',
	#superclass : 'NTSpTestCase',
	#instVars : [
		'mainPresenter',
		'presenter'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpTagSelectionDialogTest >> setUp [

	super setUp.

	presenter := NTSpTagSelectionDialog newApplication: app.

	ressources generateNoteAndTagsTo: noteContainer
]

{ #category : 'running' }
NTSpTagSelectionDialogTest >> testFilteredTagsFor [

	self assert: (presenter filteredTagsFor: 'tag') size equals: 3.
	
	self assert: (presenter filteredTagsFor: 'tag1') size equals: 1.
	
   self assert: (presenter filteredTagsFor: 'ZZZZ') size equals: 0
]
