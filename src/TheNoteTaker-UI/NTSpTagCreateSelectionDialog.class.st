Class {
	#name : 'NTSpTagCreateSelectionDialog',
	#superclass : 'NTSpTagSelectionDialog',
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'initialization' }
NTSpTagCreateSelectionDialog >> initializePresenters [

	super initializePresenters.

	searchTextPresenter
		whenSubmitDo: [ :newTagName | self addTagNamed: newTagName ]
]
