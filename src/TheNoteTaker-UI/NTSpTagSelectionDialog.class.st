Class {
	#name : 'NTSpTagSelectionDialog',
	#superclass : 'SpSelectMultipleDialog',
	#instVars : [
		'searchTextPresenter'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'adding' }
NTSpTagSelectionDialog >> addTagNamed: aString [

	self application noteTakerContainer tagNamed: aString.
	searchTextPresenter text: ''.
	selectedItems add: aString
]

{ #category : 'adding' }
NTSpTagSelectionDialog >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: searchTextPresenter expand: false;
		  add: table1;
		  yourself
]

{ #category : 'adding' }
NTSpTagSelectionDialog >> filteredTagsFor: aString [
	"Answer a <Collection> of <NTNoteObject> whose names match aString"

	^ (self application noteTakerContainer tagsNameMatching: aString) collect: [ :each | each tagName ]
]

{ #category : 'initialization' }
NTSpTagSelectionDialog >> initializePresenters [

	super initializePresenters.

	searchTextPresenter := self newTextInput
		                       help:
			                       'Search a tag by just typing a name. Create it if he doesn t exist';
		                       placeholder: 'Type note to search or create';
		                       whenTextChangedDo: [ self updateTagsList ];
		                       "whenSubmitDo: [ :newTagName |
				                       searchTextPresenter text: ''.
				                       selectedItems add: newTagName ];"
		                       yourself
]

{ #category : 'adding' }
NTSpTagSelectionDialog >> updateTagsList [

	| filteredItems |
	filteredItems := searchTextPresenter text
		                 ifEmpty: [ self filteredTagsFor: '' ]
		                 ifNotEmpty: [ :pattern |
		                 self filteredTagsFor: pattern ].

	self items: filteredItems.
]
