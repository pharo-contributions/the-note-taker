"
Open a presenter with a search bar and a list of tag.

If we use allowTagCreation, so when we submit the text in searchBar ( Enter character ), a new Tag is created
"
Class {
	#name : 'NTTodoSpTagSelectionDialog',
	#superclass : 'SpSelectMultipleDialog',
	#instVars : [
		'searchTextPresenter'
	],
	#category : 'TheNoteTaker-Todo-UI-Core',
	#package : 'TheNoteTaker-Todo-UI',
	#tag : 'Core'
}

{ #category : 'adding' }
NTTodoSpTagSelectionDialog >> addTagNamed: aString [

	self application taskContainer ensureTagNamed: aString.
	searchTextPresenter text: ''.
	selectedItems add: aString
]

{ #category : 'initialization' }
NTTodoSpTagSelectionDialog >> allowTagCreation [

	searchTextPresenter
		help:
			'Search a tag by just typing a name. Create it if he doesn t exist';
		placeholder: 'Type note to search or create';
		whenSubmitDo: [ :newTagName | self addTagNamed: newTagName ]
]

{ #category : 'adding' }
NTTodoSpTagSelectionDialog >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: searchTextPresenter expand: false;
		  add: table1;
		  yourself
]

{ #category : 'adding' }
NTTodoSpTagSelectionDialog >> filteredTagsFor: aString [
	"Answer a <Collection> of <NTNoteObject> whose names match aString"

	^ (self application taskContainer tagsNameMatching: aString)
		  collect: [ :each | each tagName ]
]

{ #category : 'initialization' }
NTTodoSpTagSelectionDialog >> initializePresenters [

	super initializePresenters.

	searchTextPresenter := self newTextInput
		                       help: 'Search a tag by just typing a name.';
		                       placeholder: 'Type note to search';
		                       whenTextChangedDo: [ :text |
			                       self items: (self filteredTagsFor: text) ];
		                       yourself
]

{ #category : 'adding' }
NTTodoSpTagSelectionDialog >> selectedItems: aTagNameCollection [

	selectedItems addAll: aTagNameCollection
]
