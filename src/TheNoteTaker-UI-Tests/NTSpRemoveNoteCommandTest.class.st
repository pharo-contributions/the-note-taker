Class {
	#name : 'NTSpRemoveNoteCommandTest',
	#superclass : 'NTSpCommandTest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpRemoveNoteCommandTest >> setUp [

	super setUp.

	command := NTSpRemoveNoteCommand new context: indexPresenter
]

{ #category : 'tests' }
NTSpRemoveNoteCommandTest >> testRemoveSelectedNotes [

	indexPresenter selectNote: ressources getNote1.
	indexPresenter selectNote: ressources getNote2.

	self assert: indexPresenter items size equals: 3.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter accept ]
		during: [ command execute ].

	self assert: indexPresenter items size equals: 1.
]
