Class {
	#name : 'NTSpNoteTakerMainUITest',
	#superclass : 'TestCase',
	#instVars : [
		'app',
		'presenter',
		'notesIndexPresenter',
		'notesTaker',
		'notesContentPresenter',
		'memoryFS'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpNoteTakerMainUITest >> setUp [

	app := NTSpApplication new.
	presenter := app newPresenter: NTSpNoteTakerMainUI.
	notesIndexPresenter := presenter notesIndexPresenter.
	notesTaker := presenter noteTaker.
	notesContentPresenter := presenter notesContentPresenter.
	memoryFS := FileSystem memory. 
]

{ #category : 'running' }
NTSpNoteTakerMainUITest >> tearDown [

	notesTaker removeNotes: notesTaker notes.
	super tearDown.
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddContentThenNameNoteIsInISOFormat [
	
	| note |
		note := notesTaker addNoteNamed: 'newNote'.
	notesIndexPresenter selectNote: note. 
	notesContentPresenter contents: 'It''s just a test'.
	notesContentPresenter contentPresenter save: (notesContentPresenter contents). 
	self assert: note contents equals: 'It''s just a test'.

]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsName [ 
	
	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	notesTaker addNoteNamed: 'note1'.
	self assert: notesIndexPresenter items size equals: sizeNotesBeforeAddNote + 1.
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
