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

	indexPresenter selectNote: ressources note1.
	indexPresenter selectNote: ressources note2.

	self assert: indexPresenter items size equals: 3.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter accept ]
		during: [ command execute ].

	self assert: indexPresenter items size equals: 1.
]
