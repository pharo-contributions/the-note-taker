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
	
	| noteFileName |
	super setUp. 
	memoryFS := FileSystem memory. 
	
	app := NTSpApplication new.
	presenter := app newPresenter: NTSpNoteTakerMainUI.
	notesIndexPresenter := presenter notesIndexPresenter.
	notesTaker := presenter noteTaker.
	notesContentPresenter := presenter notesContentPresenter.

	noteFile := memoryFS workingDirectory / 'newNote.md'. 
	noteFile writeStreamDo: [ : stream | stream nextPutAll: 'new note' ].
	
	noteFileName := (notesTaker addNoteFromFileReference: noteFile) fileName. 
	note := notesTaker noteNamed: noteFileName.
	notesContentPresenter newNote: note.
	
	
]

{ #category : 'running' }
NTSpNoteTakerMainUITest >> tearDown [

	notesTaker removeNotes: notesTaker notes.
	noteFile ensureDelete.
	"notesContentPresenter editorPresenter note fileReference delete."
	super tearDown.
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddContent [
	
	| tempNote |
	notesContentPresenter textInputText: 'It''s just a test'.
	
	tempNote := notesContentPresenter note.
	tempNote folderReference: memoryFS workingDirectory.
	notesContentPresenter saveFile.

	self assert: note contents equals: 'It''s just a test'
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsContents [ 
	
	| tempNote |
	notesContentPresenter startNewFile.
	notesContentPresenter textInputText: 'just a new note'.
	
	tempNote := notesContentPresenter note.
	tempNote folderReference: memoryFS workingDirectory.
	
	notesContentPresenter saveFile.
	
	self assert: notesContentPresenter note exists.
	self assert: (notesContentPresenter note fileReference basename includesSubstring: 'just a new').
	
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
	
	| tempNote |
	notesContentPresenter textInputText: 'It''s just a test'.
	
	tempNote := notesContentPresenter note.
	tempNote folderReference: memoryFS workingDirectory.
	
	notesContentPresenter saveFile.

	self assert: note contents equals: 'It''s just a test' 
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testNameNoteIsInISOFormat [
	" add new note in the note taker, its contents and save it"

	| date tempNote |
	date := DateAndTime now asDate yyyymmdd.
	
	tempNote := notesContentPresenter note.
	tempNote folderReference: memoryFS workingDirectory.
	
	notesContentPresenter saveFile.

	self assert: (note fileName beginsWith: date).
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testNoteSearch [

	| toolbar nameOfNoteToSearch result anotherNameNoteToSearch | self skip.
	notesTaker addNoteNamed: 'newNote'.
	notesTaker addNoteNamed: 'anotherNote'.
	notesTaker addNoteNamed: 'thirdNote'.
	notesTaker notes.
	
	toolbar := presenter notesToolbarPresenter.
	nameOfNoteToSearch := 'newNote'.
	result := toolbar filteredNotesFor: nameOfNoteToSearch.
	self assert: result size equals: 2.
	anotherNameNoteToSearch := 'nnn'.
	result := toolbar filteredNotesFor: anotherNameNoteToSearch.
	self assert: result size equals: 0
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testRemoveNote [ 
	
	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	notesTaker removeNoteNamed: (notesTaker addNoteNamed: 'note2') fileName.
	self assert: notesIndexPresenter items size equals: sizeNotesBeforeAddNote. 
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testSelectANote [

	notesTaker addNoteNamed: 'anotherNote'.
	notesIndexPresenter selectNote: notesIndexPresenter items first.

	presenter selectedNote contents: 'anotherNote'.
	notesContentPresenter openNote: presenter selectedNote. 
	
	self assert: notesContentPresenter textInputText equals: 'anotherNote'.


]
