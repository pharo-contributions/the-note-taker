Class {
	#name : 'NTSpNoteTakerMainUITest',
	#superclass : 'NTSpApplicationTest',
	#instVars : [
		'presenter',
		'notesIndexPresenter',
		'notesContentPresenter',
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

	presenter := app newPresenter: NTSpNoteTakerMainUI.
	notesIndexPresenter := presenter notesIndexPresenter.
	notesContentPresenter := presenter notesEditorPresenter.

	noteFile := memoryFS workingDirectory / 'newNote.md'.
	noteFile writeStreamDo: [ :stream | stream nextPutAll: 'new note' ].

	noteFileName := (noteContainer addNoteFromFileReference: noteFile)
		                fileName.
	note := noteContainer noteNamed: noteFileName.
	notesContentPresenter note: note
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
   notesContentPresenter noNote.
	notesContentPresenter textInputText: 'just a new note'.

	tempNote := notesContentPresenter note.
	tempNote folderReference: memoryFS workingDirectory.

	notesContentPresenter saveFile.

	self assert: notesContentPresenter note exists.
	self assert:
		(notesContentPresenter note fileReference basename
			 includesSubstring: 'justanew')
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsName [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	noteContainer addNoteNamed: 'note1'.
	self
		assert: notesIndexPresenter items size
		equals: sizeNotesBeforeAddNote + 1
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
NTSpNoteTakerMainUITest >> testSelectANote [

	noteContainer addNoteNamed: 'anotherNote'.
	notesIndexPresenter selectNote: notesIndexPresenter items first.

	notesIndexPresenter selectedNote contents: 'anotherNote'.
	notesContentPresenter note: notesIndexPresenter selectedNote.

	self
		assert: notesContentPresenter textInputText
		equals: 'anotherNote'
]
