"
Open a presenter with a search bar and a list of tag.
We can use the search bar for filter the tags.
We can select multiple tags.

When we click on accept, return the selected tags.

If we use allowTagCreation, so when we submit the text in searchBar ( Enter character ), a new Tag is created
"
Class {
	#name : 'NTTagSelectionDialog',
	#superclass : 'SpSelectMultipleDialog',
	#instVars : [
		'searchTextPresenter'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'adding' }
NTTagSelectionDialog >> addTagNamed: aString [

	self application noteTakerContainer ensureTagNamed: aString.
	searchTextPresenter text: ''.
	selectedItems add: aString
]

{ #category : 'initialization' }
NTTagSelectionDialog >> allowTagCreation [

	searchTextPresenter
		help:
			'Search a tag by just typing a name. Create it if it doesn''t exist';
		placeholder: 'Type note to search or create';
		whenSubmitDo: [ :newTagName | self addTagNamed: newTagName ]
]

{ #category : 'layout' }
NTTagSelectionDialog >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: searchTextPresenter expand: false;
		  add: table1;
		  yourself
]

{ #category : 'filtering' }
NTTagSelectionDialog >> filteredTagsFor: aString [
	"Answer a <Collection> of <NTNoteObject> whose names match aString"

	^ (self application noteTakerContainer tagsNameMatching: aString) collect: [ :each | each tagName ]
]

{ #category : 'initialization' }
NTTagSelectionDialog >> initializePresenters [

	super initializePresenters.
	searchTextPresenter := self newTextInput
		help: 'Search a tag by just typing a name.';
		placeholder: 'Type note to search';
		whenTextChangedDo: [ :text |
			self 
				items: (self filteredTagsFor: text) ];
		yourself
]

{ #category : 'selection' }
NTTagSelectionDialog >> selectedItems: aTagNameCollection [

	selectedItems addAll: aTagNameCollection
]
