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
		'note',
		'noteFile'
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

	noteFile := memoryFS workingDirectory / 'newNote.md'. 
	noteFile writeStreamDo: [ : stream | stream nextPutAll: 'new note' ]. 
	
	notesTaker addNoteFromFileReference: noteFile. 
	note := notesTaker noteNamed: 'newNote'. 
	notesContentPresenter editorPresenter newNote: note.
	
	
]

{ #category : 'running' }
NTSpNoteTakerMainUITest >> tearDown [

	notesTaker removeNotes: notesTaker notes.
	noteFile ensureDelete.
	notesContentPresenter editorPresenter note fileReference delete.
	super tearDown.
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddContent [
	
	notesContentPresenter contents: 'It''s just a test'.
	notesContentPresenter editorPresenter saveFile.

	self assert: note contents equals: 'It''s just a test'
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsContents [ 
	
	notesContentPresenter editorPresenter startNewFile.
	notesContentPresenter contents: 'just a new note'.
	notesContentPresenter editorPresenter saveFile.
	
	self assert: notesContentPresenter editorPresenter mdFile exists.
	self assert: (notesContentPresenter editorPresenter mdFile basename includesSubstring: 'justanew').
	
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsName [ 
	
	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	notesTaker addNoteNamed: 'note1'.
	self assert: notesIndexPresenter items size equals: sizeNotesBeforeAddNote + 1.
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testImportNote [ 
	
	notesContentPresenter contents: 'It''s just a test'.
	notesContentPresenter editorPresenter saveFile.

	self assert: note contents equals: 'It''s just a test' 
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
	notesTaker addNoteNamed: 'newNote'.
	notesTaker addNoteNamed: 'anotherNote'.
	notesTaker addNoteNamed: 'thirdNote'.
	self halt.
	notesTaker notes.
	
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

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testSelectANote [

	notesTaker addNoteNamed: 'anotherNote'.
	notesIndexPresenter selectNote: notesIndexPresenter items first.

	presenter selectedNote contents: 'anotherNote'.
	notesContentPresenter editorPresenter openNote: presenter selectedNote. 
	
	self assert: notesContentPresenter editorPresenter textInputText equals: 'anotherNote'.


]
