"
Open a presenter with a search bar and a list of tag.
We can use the search bar for filter the tags.
We can select multiple tags.

When we click on accept, return the selected tags.

If we use allowTagCreation, so when we submit the text in searchBar ( Enter character ), a new Tag is created
"
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

	self application noteTakerContainer ensureTagNamed: aString.
	searchTextPresenter text: ''.
	selectedItems add: aString
]

{ #category : 'initialization' }
NTSpTagSelectionDialog >> allowTagCreation [

	searchTextPresenter
		help:
			'Search a tag by just typing a name. Create it if he doesn t exist';
		placeholder: 'Type note to search or create';
		whenSubmitDo: [ :newTagName | self addTagNamed: newTagName ]
]

{ #category : 'layout' }
NTSpTagSelectionDialog >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: searchTextPresenter expand: false;
		  add: table1;
		  yourself
]

{ #category : 'filtering' }
NTSpTagSelectionDialog >> filteredTagsFor: aString [
	"Answer a <Collection> of <NTNoteObject> whose names match aString"

	^ (self application noteTakerContainer tagsNameMatching: aString) collect: [ :each | each tagName ]
]

{ #category : 'initialization' }
NTSpTagSelectionDialog >> initializePresenters [

	super initializePresenters.

	searchTextPresenter := self newTextInput
		                       help: 'Search a tag by just typing a name.';
		                       placeholder: 'Type note to search';
		                       whenTextChangedDo: [ :text |
			                       self items: (self filteredTagsFor: text) ];
		                       yourself
]

{ #category : 'selection' }
NTSpTagSelectionDialog >> selectedItems: aTagNameCollection [

	selectedItems addAll: aTagNameCollection
]
