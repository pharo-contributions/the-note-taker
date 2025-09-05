Class {
	#name : 'NTSpAddTagCommandTest',
	#superclass : 'NTSpCommandTest',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpAddTagCommandTest >> setUp [

	super setUp.

	command := NTSpAddTagCommand new context: indexPresenter
]

{ #category : 'running' }
NTSpAddTagCommandTest >> testAddTagDontDeselectNotes [

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

	self assert:
		(indexPresenter selectedNotes includes: ressources getNote1)
]

{ #category : 'running' }
NTSpAddTagCommandTest >> testAddTagOfSelectedNotes [

	| tagCollection |
	indexPresenter selectNote: ressources getNote3.

	tagCollection := ressources getNote3 tags.

	self assertEmpty: tagCollection.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems:
					#( 'tag1' 'tag2' 'tag3' ).
				aDialogPresenter presenter accept ]
		during: [ command execute ].

	self assert: tagCollection size equals: 3
]
