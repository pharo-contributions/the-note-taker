"
I test the new NoteTaker UI on an in-memory file system.
"
Class {
	#name : 'NT2MainPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'memoryFS',
		'app',
		'presenter'
	],
	#category : 'TheNoteTaker-UI2-Tests',
	#package : 'TheNoteTaker-UI2-Tests'
}

{ #category : 'helpers' }
NT2MainPresenterTest >> noteFiles [

	^ memoryFS files
]

{ #category : 'helpers' }
NT2MainPresenterTest >> savedNote: aString tags: aCollection [

	| note |
	note := app newNote.
	note contents: aString.
	aCollection do: [ :each | app addTagNamed: each to: note ].
	app saveNote: note.
	presenter noteList refresh.
	^ note
]

{ #category : 'running' }
NT2MainPresenterTest >> setUp [

	super setUp.
	memoryFS := FileSystem memory workingDirectory.
	app := NT2Application new.
	app folder: memoryFS.
	presenter := NT2MainPresenter newApplication: app
]

{ #category : 'running' }
NT2MainPresenterTest >> tearDown [

	presenter editor cancelAutosave.
	app closeAllWindows.
	super tearDown
]

{ #category : 'tests - tags' }
NT2MainPresenterTest >> testAddTagCreatesTagAndSavesNote [

	| note |
	note := self savedNote: 'note' tags: #(  ).
	presenter noteList selectNote: note.

	presenter editor tagField addTagNamed: ' work '.

	self assert: (note tags collect: [ :t | t tagName ]) asArray equals: #( 'work' ).
	self assert: (presenter noteList tagNames includes: 'work').
	self assert: ((NTContainer new
			  importFolder: memoryFS;
			  notes) first tags anySatisfy: [ :t | t tagName = 'work' ])
]

{ #category : 'tests - editing' }
NT2MainPresenterTest >> testDeleteMovesNoteToTrashAndSelectsNext [

	| first second |
	first := self savedNote: 'first' tags: #(  ).
	second := self savedNote: 'second' tags: #(  ).
	presenter noteList selectNote: second.

	presenter deleteNote.

	self assert: app container notes asArray equals: { first }.
	self assert: (memoryFS / '.trash') files size equals: 1.
	self assert: presenter editor note equals: first
]

{ #category : 'tests - editing' }
NT2MainPresenterTest >> testEmptyNewNoteIsDiscardedWhenLeft [

	| other |
	other := self savedNote: 'other' tags: #(  ).
	presenter newNote.

	presenter noteList selectNote: other.

	self assert: app container notes asArray equals: { other }.
	self assert: self noteFiles size equals: 1
]

{ #category : 'tests - editing' }
NT2MainPresenterTest >> testNewNoteIsSelectedButNotSavedUntilTyped [

	presenter newNote.

	self assert: presenter editor note notNil.
	self assert: presenter noteList selectedNote equals: presenter editor note.
	self assertEmpty: self noteFiles
]

{ #category : 'tests - list' }
NT2MainPresenterTest >> testNotesAreListedNewestFirst [

	| old new |
	old := self savedNote: 'old' tags: #(  ).
	new := self savedNote: 'new' tags: #(  ).
	old modificationDate: (DateAndTime fromString: '2020-01-01').
	presenter noteList refresh.

	self assert: presenter noteList notes asArray equals: {
			new.
			old }
]

{ #category : 'tests - editing' }
NT2MainPresenterTest >> testNotesWithSameFirstLineGetDistinctFiles [

	presenter newNote.
	presenter editor textInput text: 'Same'.
	presenter newNote.
	presenter editor textInput text: 'Same'.
	presenter editor autosaveNow.

	self assert: self noteFiles size equals: 2
]

{ #category : 'tests - preview' }
NT2MainPresenterTest >> testPreviewRendersMarkdown [

	| note |
	note := self savedNote: '# Title' , String lf , 'some **bold** text' tags: #(  ).
	presenter noteList selectNote: note.

	presenter editor modeButton state: true.

	self assert: (presenter editor previewText asString includesSubstring: 'Title').
	self deny: (presenter editor previewText asString includesSubstring: '**')
]

{ #category : 'tests - tags' }
NT2MainPresenterTest >> testRemovingLastUseOfTagRemovesItFromFilter [

	| note |
	note := self savedNote: 'note' tags: #( 'work' ).
	presenter noteList selectNote: note.

	presenter editor tagField removeTag: note tags anyOne.

	self assertEmpty: note tags.
	self deny: (presenter noteList tagNames includes: 'work')
]

{ #category : 'tests - list' }
NT2MainPresenterTest >> testSearchAndTagFilterCombine [

	self savedNote: 'alpha' tags: #( 'work' ).
	self savedNote: 'beta' tags: #( 'work' ).
	self savedNote: 'alpha again' tags: #(  ).

	presenter noteList selectTagsNamed: #( 'work' ).
	presenter noteList searchText: 'alpha'.

	self assert: presenter noteList notes size equals: 1.
	self assert: presenter noteList notes first title equals: 'alpha'
]

{ #category : 'tests - list' }
NT2MainPresenterTest >> testSearchFiltersOnContents [

	self savedNote: 'apple' , String lf , 'fruit' tags: #(  ).
	self savedNote: 'carrot' tags: #(  ).

	presenter noteList searchText: 'fruit'.

	self assert: presenter noteList notes size equals: 1.
	self assert: presenter noteList notes first title equals: 'apple'
]

{ #category : 'tests - editing' }
NT2MainPresenterTest >> testSwitchingNoteSavesTypedContents [

	| other |
	other := self savedNote: 'other' tags: #(  ).
	presenter newNote.
	presenter editor textInput text: 'Hello' , String lf , 'world'.
	self assert: presenter editor isDirty.

	presenter noteList selectNote: other.

	self assert: (self noteFiles anySatisfy: [ :f | f basename endsWith: '_Hello.md' ]).
	self deny: presenter editor isDirty
]

{ #category : 'tests - list' }
NT2MainPresenterTest >> testTagFilterKeepsNotesHavingAllSelectedTags [

	| both |
	both := self savedNote: 'both' tags: #( 'work' 'meeting' ).
	self savedNote: 'work only' tags: #( 'work' ).

	presenter noteList selectTagsNamed: #( 'work' ).
	self assert: presenter noteList notes size equals: 2.

	presenter noteList selectTagsNamed: #( 'work' 'meeting' ).
	self assert: presenter noteList notes asArray equals: { both }
]

{ #category : 'tests - list' }
NT2MainPresenterTest >> testTitleIsFirstLineWithoutHeadingMarks [

	self assert: (NT2Application displayTitleOf: (NTNote content: '## Hello' , String lf , 'body')) equals: 'Hello'.
	self assert: (NT2Application displayTitleOf: (NTNote content: '')) equals: 'unnamed'
]

{ #category : 'tests - preview' }
NT2MainPresenterTest >> testTogglingPreviewInOpenWindowDoesNotMarkNoteDirty [

	| note modificationDate |
	note := self savedNote: 'note' , String lf , 'body' tags: #(  ).
	modificationDate := note modificationDate.
	app start.
	app mainPresenter noteList selectNote: note.

	app mainPresenter editor modeButton state: true.
	app mainPresenter editor modeButton state: false.

	self deny: app mainPresenter editor isDirty.
	self assert: note modificationDate equals: modificationDate
]

{ #category : 'tests - editing' }
NT2MainPresenterTest >> testTypingSchedulesAutosave [

	presenter newNote.
	presenter editor textInput text: 'Draft'.

	self assert: presenter editor hasPendingAutosave.
	presenter editor autosaveNow.

	self deny: presenter editor isDirty.
	self deny: presenter editor hasPendingAutosave.
	self assert: self noteFiles size equals: 1
]
