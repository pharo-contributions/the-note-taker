Class {
	#name : 'NTSpTagCreateSelectionDialog',
	#superclass : 'NTSpTagSelectionDialog',
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'initialization' }
NTSpTagCreateSelectionDialog >> addTagNamed: aString [

	self application noteTakerContainer tagNamed: aString.
	searchTextPresenter text: ''.
	selectedItems add: aString
]

{ #category : 'initialization' }
NTSpTagCreateSelectionDialog >> initializePresenters [

	super initializePresenters.

	searchTextPresenter
		help:
			'Search a tag by just typing a name. Create it if he doesn t exist';
		placeholder: 'Type note to search or create'.

	searchTextPresenter whenSubmitDo: [ :newTagName |
		self addTagNamed: newTagName ]
]
