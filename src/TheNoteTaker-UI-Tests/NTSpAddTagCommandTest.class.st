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
