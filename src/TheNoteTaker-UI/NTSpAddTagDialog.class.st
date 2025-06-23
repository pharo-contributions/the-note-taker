Class {
	#name : 'NTSpAddTagDialog',
	#superclass : 'SpSelectMultipleDialog',
	#instVars : [
		'searchTextPresenter'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'adding' }
NTSpAddTagDialog >> addTagNamed: aString [

	self application noteTakerContainer tagNamed: aString.
	searchTextPresenter text: ''.
	selectedItems add: aString
]

{ #category : 'adding' }
NTSpAddTagDialog >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: searchTextPresenter expand: false;
		  add: table1;
		  yourself
]

{ #category : 'adding' }
NTSpAddTagDialog >> filteredTagsFor: aString [
	"Answer a <Collection> of <NTNoteObject> whose names match aString"

	^ (self application noteTakerContainer tagsNameMatching: aString) collect: [ :each | each tagName ]
]

{ #category : 'initialization' }
NTSpAddTagDialog >> initializePresenters [

	super initializePresenters.

	searchTextPresenter := self newTextInput
		                       help:
			                       'Search a tag by just typing a name. Create it if he doesn t exist';
		                       placeholder: 'Type note to search or create';
		                       whenTextChangedDo: [ self updateTagsList ];
		                       whenSubmitDo: [ :newTagName |
			                       self addTagNamed: newTagName ];
		                       yourself
]

{ #category : 'adding' }
NTSpAddTagDialog >> updateTagsList [

	| filteredItems |
	filteredItems := searchTextPresenter text
		                 ifEmpty: [ self filteredTagsFor: '' ]
		                 ifNotEmpty: [ :pattern |
		                 self filteredTagsFor: pattern ].

	self items: filteredItems.
]
