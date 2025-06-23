Class {
	#name : 'NTBasicTest',
	#superclass : 'TestCase',
	#instVars : [
		'noteTakerContainer'
	],
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTBasicTest class >> resources [
	^ { NTTestResource }
]

{ #category : 'running' }
NTBasicTest >> resource [

	^ NTTestResource current
]

{ #category : 'running' }
NTBasicTest >> setUp [

	super setUp.
	noteTakerContainer := NTContainer new
]

{ #category : 'accessing' }
NTBasicTest >> simplestNoteName [

	^ 'testMock Note'
]

{ #category : 'tests' }
NTBasicTest >> testAddNewNote [

	self
		deny: noteTakerContainer hasNotes
		description: 'It tests that yet we haven''t any notes'.

	noteTakerContainer addNoteNamed: self simplestNoteName.

	self assert: noteTakerContainer notesCount equals: 1
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testAddingAndRemovingNotes [
	"Test adding and removing notes, and ensure that the singleton is updated accordingly"

	| noteName notes |
	noteName := self simplestNoteName.
	noteName := (noteTakerContainer addNoteNamed: noteName) fileName.
	self assert: (noteTakerContainer hasNoteNamed: noteName).

	notes := noteTakerContainer notes.
	self assert: notes size equals: 1.

	noteTakerContainer removeNoteNamed: noteName.
	self deny: (noteTakerContainer hasNoteNamed: noteName).
	self assertEmpty: noteTakerContainer notes
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testAddingNotesWithSameName [
	"Test adding notes with the same name"

	| noteName notes |
	noteName := self simplestNoteName.

	noteName := (noteTakerContainer addNoteNamed: noteName) fileName.
	noteTakerContainer addNoteNamed: noteName.

	notes := noteTakerContainer notes.

	"Two notes should be added"
	self assert: notes size equals: 2.
	self assert: (noteTakerContainer hasNoteNamed: noteName).
	self
		assert: (noteTakerContainer noteNamed: noteName) isNote
		description: 'Check if the note is an instance of Note class'
]

{ #category : 'tests' }
NTBasicTest >> testCreateNoteObject [

	| aNote |
	aNote := noteTakerContainer addNoteNamed: self simplestNoteName.
	self assert: aNote isNote
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testMultipleNotesCreationAndAccess [
	"Test creating multiple notes and accessing them"

	| noteFileName noteNames notes |
	noteNames := self threeNoteNames.

	noteFileName := noteNames collect: [ :name |
		                (noteTakerContainer addNoteNamed: name) fileName ].
	notes := noteTakerContainer notes.

	self assert: notes size equals: noteNames size.
	noteFileName do: [ :name |
		self assert: (noteTakerContainer hasNoteNamed: name) ]
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNoteDeletion [
	"Test creating notes and deleting one of them"

	| noteNames notes secondNoteName tempNotes |
	noteNames := self threeNoteNames.

	tempNotes := noteNames collect: [ :name |
		             noteTakerContainer addNoteNamed: name ].

	secondNoteName := tempNotes second fileName.

	noteTakerContainer removeNoteNamed: secondNoteName.
	notes := noteTakerContainer notes.

	self assert: notes size equals: noteNames size - 1.
	self deny: (noteTakerContainer hasNoteNamed: secondNoteName)
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNoteObjectsContainValidNotes [
	"Test that the note objects returned by the container are valid instances of Note class"

	| noteName noteObject note |
	noteName := self simplestNoteName.

	note := noteTakerContainer addNoteNamed: noteName.

	noteObject := noteTakerContainer noteNamed: note fileName.
	self assert: noteObject isNote
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNotesInitialization [
	"Test that the notes singleton is initialized correctly"

	self assertEmpty: noteTakerContainer notes
]

{ #category : 'tests' }
NTBasicTest >> testRemoveNote [

	| note |
	note := noteTakerContainer addNoteNamed: self simplestNoteName.
	self assert: noteTakerContainer notesCount equals: 1.
	noteTakerContainer removeNoteNamed: note fileName.
	self
		deny: noteTakerContainer hasNotes
		description: 'It tests that now we haven''t any notes' 
]

{ #category : 'accessing' }
NTBasicTest >> threeNoteNames [

	^ { 
		self simplestNoteName , '1' .
		self simplestNoteName , '2' .
		self simplestNoteName , '3' 
		}.
]
