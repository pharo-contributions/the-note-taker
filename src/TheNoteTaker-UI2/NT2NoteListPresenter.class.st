"
I show the tag filter and the notes matching the selected tags (all of them) and the search text, newest first.
"
Class {
	#name : 'NT2NoteListPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'tagList',
		'noteTable',
		'searchText'
	],
	#category : 'TheNoteTaker-UI2',
	#package : 'TheNoteTaker-UI2'
}

{ #category : 'filtering' }
NT2NoteListPresenter >> clearFilters [

	searchText := ''.
	tagList unselectAll
]

{ #category : 'initialization' }
NT2NoteListPresenter >> connectPresenters [

	tagList whenSelectionChangedDo: [ self refreshNotes ]
]

{ #category : 'accessing' }
NT2NoteListPresenter >> container [

	^ self application container
]

{ #category : 'layout' }
NT2NoteListPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: (self newLabel label: 'Tags') expand: false;
		  add: tagList height: 90;
		  add: noteTable;
		  yourself
]

{ #category : 'filtering' }
NT2NoteListPresenter >> filteredNotes [
	"Answer the notes having all the selected tags and matching the search text, newest first"

	| notes |
	notes := searchText isEmpty
		         ifTrue: [ self container notes ]
		         ifFalse: [ self container notesContentsMatching: searchText ].
	notes := self container notes: notes withTags: tagList selectedItems.
	^ notes asArray sort: [ :a :b | a modificationDate > b modificationDate ]
]

{ #category : 'initialization' }
NT2NoteListPresenter >> initializePresenters [

	searchText := ''.
	tagList := self newList
		           beMultipleSelection;
		           display: [ :tag | tag tagName ];
		           yourself.
	noteTable := self newTable
		             addColumn: (SpStringTableColumn title: 'Title' evaluated: [ :note | NT2Application displayTitleOf: note ]);
		             addColumn: ((SpStringTableColumn title: 'Modified' evaluated: [ :note | note modificationDate asDate yyyymmdd ])
				              width: 90;
				              yourself);
		             yourself
]

{ #category : 'accessing' }
NT2NoteListPresenter >> notes [

	^ noteTable items
]

{ #category : 'refreshing' }
NT2NoteListPresenter >> refresh [

	self refreshTags.
	self refreshNotes
]

{ #category : 'refreshing' }
NT2NoteListPresenter >> refreshDisplay [
	"Redraw the rows, for example after the title of the selected note changed"

	noteTable refresh
]

{ #category : 'refreshing' }
NT2NoteListPresenter >> refreshNotes [

	| selected notes |
	selected := noteTable selectedItem.
	notes := self filteredNotes.
	noteTable items: notes.
	(selected notNil and: [ notes includes: selected ]) ifTrue: [ noteTable selectItem: selected ]
]

{ #category : 'refreshing' }
NT2NoteListPresenter >> refreshTags [

	| selected tags |
	selected := tagList selectedItems.
	tags := self container tags asArray sort: [ :a :b | a tagName < b tagName ].
	tagList items: tags.
	tagList selectItems: (selected select: [ :tag | tags includes: tag ])
]

{ #category : 'filtering' }
NT2NoteListPresenter >> searchText: aString [

	searchText := aString.
	self refreshNotes
]

{ #category : 'selection' }
NT2NoteListPresenter >> selectNote: aNTNote [

	noteTable selectItem: aNTNote
]

{ #category : 'filtering' }
NT2NoteListPresenter >> selectTagsNamed: aCollection [

	tagList selectItems: (tagList items select: [ :tag | aCollection includes: tag tagName ])
]

{ #category : 'accessing' }
NT2NoteListPresenter >> selectedNote [

	^ noteTable selectedItem
]

{ #category : 'accessing' }
NT2NoteListPresenter >> tagNames [

	^ tagList items collect: [ :tag | tag tagName ]
]

{ #category : 'initialization' }
NT2NoteListPresenter >> updatePresenter [

	self refresh
]

{ #category : 'events' }
NT2NoteListPresenter >> whenNoteSelectedDo: aBlock [

	noteTable whenSelectionChangedDo: [ aBlock value: noteTable selectedItem ]
]
