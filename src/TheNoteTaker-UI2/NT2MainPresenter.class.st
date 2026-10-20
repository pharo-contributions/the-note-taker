"
I am the main window of the new NoteTaker UI: a toolbar, the note list on the left and the editor on the right.
"
Class {
	#name : 'NT2MainPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'newButton',
		'deleteButton',
		'searchInput',
		'noteList',
		'editor'
	],
	#category : 'TheNoteTaker-UI2',
	#package : 'TheNoteTaker-UI2'
}

{ #category : 'initialization' }
NT2MainPresenter >> connectPresenters [

	searchInput whenTextChangedDo: [ :text | noteList searchText: text asString ].
	noteList whenNoteSelectedDo: [ :aNote | aNote ifNotNil: [ self showNote: aNote ] ].
	editor whenNoteChangedDo: [ :aNote |
			noteList refreshDisplay.
			self updateTitle ].
	editor whenNoteSavedDo: [ :aNote |
			noteList refresh.
			self updateTitle ]
]

{ #category : 'layout' }
NT2MainPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 4;
		  add: (SpBoxLayout newLeftToRight
				   spacing: 4;
				   add: newButton expand: false;
				   add: deleteButton expand: false;
				   add: searchInput;
				   yourself)
		  expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 35 percent;
				   add: noteList;
				   add: editor;
				   yourself);
		  yourself
]

{ #category : 'actions' }
NT2MainPresenter >> deleteNote [
	"Move the current note to the trash and select the note which takes its place"

	| note index notes |
	note := editor note ifNil: [ ^ self ].
	index := noteList notes indexOf: note.
	editor note: nil.
	self application trashNote: note.
	noteList refresh.
	notes := noteList notes.
	notes ifEmpty: [ ^ self updateTitle ].
	noteList selectNote: (notes at: (index max: 1) ifAbsent: [ notes last ])
]

{ #category : 'actions' }
NT2MainPresenter >> discardIfEmpty: aNTNote [
	"A new note left without contents nor tags is forgotten instead of being saved as unnamed"

	aNTNote ifNil: [ ^ self ].
	((self application isUnsaved: aNTNote) and: [ aNTNote contents isEmpty and: [ aNTNote tags isEmpty ] ]) ifFalse: [ ^ self ].
	self application discardNote: aNTNote.
	noteList refresh
]

{ #category : 'accessing' }
NT2MainPresenter >> editor [

	^ editor
]

{ #category : 'initialization' }
NT2MainPresenter >> initializePresenters [

	newButton := self newButton
		             label: 'New';
		             icon: (self iconNamed: #add);
		             action: [ self newNote ];
		             yourself.
	deleteButton := self newButton
		                label: 'Delete';
		                icon: (self iconNamed: #delete);
		                help: 'Move the note to the .trash folder';
		                action: [ self deleteNote ];
		                yourself.
	searchInput := self newTextInput
		               placeholder: 'Search';
		               yourself.
	noteList := self instantiate: NT2NoteListPresenter.
	editor := self instantiate: NT2EditorPresenter
]

{ #category : 'initialization' }
NT2MainPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self noteWindowTitle;
		initialExtent: (900 @ 600) scaledByDisplayScaleFactor;
		whenClosedDo: [ editor flush ]
]

{ #category : 'actions' }
NT2MainPresenter >> newNote [

	| note |
	note := self application newNote.
	searchInput text: ''.
	noteList clearFilters.
	noteList refresh.
	noteList selectNote: note.
	editor takeKeyboardFocus
]

{ #category : 'accessing' }
NT2MainPresenter >> noteList [

	^ noteList
]

{ #category : 'accessing' }
NT2MainPresenter >> noteWindowTitle [

	| title |
	title := 'NoteTaker (new)'.
	editor note ifNil: [ ^ title ].
	title := title , ' - ' , (NT2Application displayTitleOf: editor note).
	^ editor isDirty
		  ifTrue: [ title , ' *' ]
		  ifFalse: [ title ]
]

{ #category : 'accessing' }
NT2MainPresenter >> searchInput [

	^ searchInput
]

{ #category : 'actions' }
NT2MainPresenter >> showNote: aNTNote [

	| previous |
	previous := editor note.
	previous == aNTNote ifTrue: [ ^ self ].
	editor note: aNTNote.
	self discardIfEmpty: previous.
	self updateTitle
]

{ #category : 'actions' }
NT2MainPresenter >> updateTitle [

	self withWindowDo: [ :window | window title: self noteWindowTitle ]
]
