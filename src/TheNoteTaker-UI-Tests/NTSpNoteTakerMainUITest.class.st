Class {
	#name : 'NTSpNoteTakerMainUITest',
	#superclass : 'TestCase',
	#instVars : [
		'app',
		'presenter',
		'notesIndexPresenter',
		'notesTaker',
		'notesContentPresenter',
		'memoryFS',
		'note'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpNoteTakerMainUITest >> setUp [
	
	super setUp. 
	memoryFS := FileSystem memory.
	
	app := NTSpApplication new.
	presenter := app newPresenter: NTSpNoteTakerMainUI.
	notesIndexPresenter := presenter notesIndexPresenter.
	notesTaker := presenter noteTaker.
	notesContentPresenter := presenter notesContentPresenter.

	note := notesTaker newNoteNamed: 'newNote'. 
	notesContentPresenter editorPresenter newNote: note.
	
]

{ #category : 'running' }
NTSpNoteTakerMainUITest >> tearDown [

	notesTaker removeNotes: notesTaker notes.
	super tearDown.
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddContent [
	
	notesContentPresenter contents: 'It''s just a test'.
	notesContentPresenter editorPresenter saveFile.

	self assert: note contents equals: 'It''s just a test'
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsName [ 
	
	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	notesTaker addNoteNamed: 'note1'.
	self assert: notesIndexPresenter items size equals: sizeNotesBeforeAddNote + 1.
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testNameNoteIsInISOFormat [
	" add new note in the note taker, its contents and save it"

	| date |
	date := DateAndTime now asDate yyyymmdd.
	notesContentPresenter editorPresenter saveFile.

	self assert: (note title beginsWith: date).
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testNoteSearch [

	| toolbar nameOfNoteToSearch result anotherNameNoteToSearch |
	" Add some notes to search one of them"
	notesTaker addNoteNamed: 'newNote'.
	notesTaker addNoteNamed: 'anotherNote'.
	notesTaker addNoteNamed: 'thirdNote'.

	toolbar := presenter notesToolbarPresenter.
	nameOfNoteToSearch := 'newNote'.
	result := toolbar filteredNotesFor: nameOfNoteToSearch.
	self assert: result size equals: 1.
	anotherNameNoteToSearch := 'nnn'.
	result := toolbar filteredNotesFor: anotherNameNoteToSearch.
	self assert: result size equals: 0
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testRemoveNote [ 
	
	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	notesTaker addNoteNamed: 'note2'.
	notesTaker removeNoteNamed: 'note2'.
	self assert: notesIndexPresenter items size equals: sizeNotesBeforeAddNote. 
]
