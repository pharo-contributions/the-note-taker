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
NTSpRemoveTagCommandTest >> testRemoveTagDontDeselectNotes [

	| tagCollection |
	indexPresenter selectNote: ressources note1.

	tagCollection := ressources note1 tags collect: [ :each |
		                 each tagName ].

	self assert: tagCollection size equals: 2.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: tagCollection.
				aDialogPresenter presenter accept ]
		during: [ command execute ].
		
	self assert: (indexPresenter selectedNotes includes: ressources note1).
]

{ #category : 'running' }
NTSpRemoveTagCommandTest >> testRemoveTagOfSelectedNotes [

	| tagCollection |
	indexPresenter selectNote: ressources note1.

	tagCollection := ressources note1 tags collect: [ :each |
		                 each tagName ].

	self assert: tagCollection size equals: 2.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: tagCollection.
				aDialogPresenter presenter accept ]
		during: [ command execute ].

	self assertEmpty: ressources note1 tags
]
