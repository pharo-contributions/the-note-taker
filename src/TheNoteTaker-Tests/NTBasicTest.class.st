Class {
	#name : 'NTBasicTest',
	#superclass : 'TestCase',
	#instVars : [
		'sing'
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
	sing := NTSingleton
]

{ #category : 'accessing' }
NTBasicTest >> simplestNoteName [

	^ 'testMock Note'
]

{ #category : 'tests' }
NTBasicTest >> testAddNewNote [

	sing safeDo: [ :unique |
		self
			deny: unique hasNotes
			description: 'It tests that yet we haven''t any notes'.

		unique addNoteNamed: self simplestNoteName.

		self assert: unique notesCount equals: 1 ]
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testAddingAndRemovingNotes [
	"Test adding and removing notes, and ensure that the singleton is updated accordingly"

	NTSingleton safeDo: [ :uniq |
		| noteName notes |
		noteName := self simplestNoteName.
		noteName := (uniq addNoteNamed: noteName) fileName.
		self assert: (uniq hasNoteNamed: noteName).

		notes := uniq notes.
		self assert: notes size equals: 1.

		uniq removeNoteNamed: noteName.
		self deny: (uniq hasNoteNamed: noteName).
		self assertEmpty: uniq notes ] 
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testAddingNotesWithSameName [
	"Test adding notes with the same name"


		sing safeDo: [  :uniq |  
	| noteName notes |
	noteName := self simplestNoteName.

	noteName := (uniq addNoteNamed: noteName) fileName.
	uniq addNoteNamed: noteName.

	notes := uniq notes.

	"Two notes should be added"
	self assert: notes size equals: 2.
	self assert: (uniq hasNoteNamed: noteName).
	self
		assert: (uniq noteNamed: noteName) isNote
		description: 'Check if the note is an instance of Note class'
		]
]

{ #category : 'tests' }
NTBasicTest >> testCreateNoteObject [

	sing safeDo: [ :uniq |
	| aNote |
	aNote := uniq addNoteNamed: self simplestNoteName.
	self assert: aNote isNote ]
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testMultipleNotesCreationAndAccess [
	"Test creating multiple notes and accessing them"

	| noteFileName |
	sing safeDo: [  :uniq |  
	| noteNames notes |
	noteNames := self threeNoteNames.

	noteFileName := noteNames collect: [ :name | (uniq addNoteNamed: name) fileName ].
	notes := uniq notes.

	self assert: notes size equals: noteNames size.
	noteFileName do: [ :name |
		self assert: (uniq hasNoteNamed: name) ]
	]
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNoteDeletion [
	"Test creating notes and deleting one of them"

	sing safeDo: [ :uniq | 
	| noteNames notes secondNoteName tempNotes |
	noteNames := self threeNoteNames.

	tempNotes := noteNames collect: [ :name | uniq addNoteNamed: name ].
	
	secondNoteName := tempNotes second fileName.

	uniq removeNoteNamed: secondNoteName.
	notes := uniq notes.

	self assert: notes size equals: noteNames size - 1.
	self deny: (uniq hasNoteNamed: secondNoteName)]
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNoteObjectsContainValidNotes [
	"Test that the note objects returned by the container are valid instances of Note class"

	sing safeDo: [  :uniq | 
	| noteName noteObject note |
	noteName := self simplestNoteName.

	note := uniq addNoteNamed: noteName.

	noteObject := uniq noteNamed: note fileName.
	self assert: noteObject isNote ] 
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNotesInitialization [
	"Test that the notes singleton is initialized correctly"

	sing safeDo: [ :uniq |
		self assertEmpty: uniq notes
		]
]

{ #category : 'tests' }
NTBasicTest >> testRemoveNote [

	sing safeDo: [ :uniq |
		|note |
		note := uniq addNoteNamed: self simplestNoteName.
		self assert: uniq notesCount equals: 1.
		uniq removeNoteNamed: note fileName.
		self
			deny: uniq hasNotes
			description: 'It tests that now we haven''t any notes' ]
]

{ #category : 'accessing' }
NTBasicTest >> threeNoteNames [

	^ { 
		self simplestNoteName , '1' .
		self simplestNoteName , '2' .
		self simplestNoteName , '3' 
		}.
]
