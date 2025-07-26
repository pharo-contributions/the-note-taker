Class {
	#name : 'NTSpRemoveTagCommandTest',
	#superclass : 'NTSpCommandTest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpRemoveTagCommandTest >> setUp [

	super setUp.

	command := NTSpRemoveTagCommand new context: indexPresenter
]

{ #category : 'running' }
NTSpRemoveTagCommandTest >> testRemoveTagOfSelectedNotes [

	| tagCollection |
	indexPresenter selectNote: ressources getNote1.

	tagCollection := ressources getNote1 tags collect: [ :each |
		                 each tagName ].

	self assert: tagCollection size equals: 2.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: tagCollection.
				aDialogPresenter presenter accept ]
		during: [ command execute ].

	self assertEmpty: ressources getNote1 tags
]
