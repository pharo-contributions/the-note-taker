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

{ #category : 'test - tags' }
NTBasicTest >> testAccessTagId [
    | tag tagID |

    tag := NTTag new.
    tagID := tag tagId.

    self 
		assert: tagID isString
		description: 'Assuming tag ID is represented as a string'
]

{ #category : 'test - tags' }
NTBasicTest >> testAccessTagName [
    | tag tagName |

    tagName := 'Sample Tag'.
    tag := NTTag newNamed: 'Tag name'.
    tag tagName: tagName.

    self assert: tag tagName equals: tagName.
]

{ #category : 'test - tags' }
NTBasicTest >> testAccessTagNotes [
    | tag note1 note2 notes |

    tag := NTTag new.
    note1 := NTNoteObject new.
    note2 := NTNoteObject new.
    tag addNote: note1.
    tag addNote: note2.
    notes := tag notes.

    self assert: (notes includes: note1).
    self assert: (notes includes: note2).
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

{ #category : 'test - tags' }
NTBasicTest >> testAddNoteToTag [

    | tag note |

    tag := NTTag new.
    note := NTNoteObject new.
    tag addNote: note.
    self assert: (tag notes includes: note).
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testAddingAndRemovingNotes [
	"Test adding and removing notes, and ensure that the singleton is updated accordingly"

	NTSingleton safeDo: [ :uniq |
		| noteName notes |
		noteName := self simplestNoteName.
		uniq addNoteNamed: noteName.
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

	uniq addNoteNamed: noteName.
	uniq addNoteNamed: noteName.

	notes := uniq notes.

	"Two notes should be added"
	self assert: notes size equals: 2.
	self assert: (uniq hasNoteNamed: self simplestNoteName).
	self
		assert: (uniq noteNamed: self simplestNoteName) isNote
		description: 'Check if the note is an instance of Note class'
		]
]

{ #category : 'tests' }
NTBasicTest >> testCreateNoteObject [

	sing safeDo: [ :uniq |
	| aNote |
	aNote := uniq newNoteNamed: self simplestNoteName.
	self assert: aNote isNote ]
]

{ #category : 'test - tags' }
NTBasicTest >> testDeleteTag [
    | tag note |

    tag := NTTag new.
    note := NTNoteObject new.
    tag addNote: note.
    note removeTag: tag.

    self assertEmpty: tag notes.
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testMultipleNotesCreationAndAccess [
	"Test creating multiple notes and accessing them"

	sing safeDo: [  :uniq |  
	| noteNames notes |
	noteNames := self threeNoteNames.

	noteNames do: [ :name | uniq addNoteNamed: name ].
	notes := uniq notes.

	self assert: notes size equals: noteNames size.
	noteNames do: [ :name |
		self assert: (uniq hasNoteNamed: name) ]
	]
]

{ #category : 'tests - dates' }
NTBasicTest >> testNoteCreationAndModificationDates [
	"Test that creation and modification dates are correctly set for notes"


		sing safeDo: [  :uniq | 
	| noteName note creationDate modificationDate |
	noteName := self simplestNoteName.

	note := uniq addNoteNamed: noteName.
	creationDate := note creationDate.
	modificationDate := note modificationDate.

	self assert: creationDate notNil.
	self assert: modificationDate notNil.
	self assert: creationDate equals: modificationDate ]

]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNoteDeletion [
	"Test creating notes and deleting one of them"

	sing safeDo: [ :uniq | 
	| noteNames notes secondNoteName |
	secondNoteName := self simplestNoteName , '2'.
	noteNames := self threeNoteNames.

	noteNames do: [ :name | uniq addNoteNamed: name ].

	uniq removeNoteNamed: secondNoteName.
	notes := uniq notes.

	self assert: notes size equals: noteNames size - 1.
	self deny: (uniq hasNoteNamed: secondNoteName)]
]

{ #category : 'tests - dates' }
NTBasicTest >> testNoteModificationDoesNotUpdateCreationDate [
	"Test that modifying a note does not update the creation date"

	sing safeDo: [ :uniq | 
	| noteName note creationDate initialModificationDate updatedCreationDate |
	noteName := 'testMock Creation Date Note'.

	note := uniq addNoteNamed: noteName.
	creationDate := note creationDate.
	initialModificationDate := note modificationDate.

	"Simulate some modification after a delay"
	Delay forSeconds: 1.
	note contents: 'testMock Modified content'.

	updatedCreationDate := note creationDate.

	self assert: updatedCreationDate equals: creationDate ]
]

{ #category : 'tests - dates' }
NTBasicTest >> testNoteModificationUpdatesModificationDate [
	"Test that modifying a note updates the modification date"

	sing safeDo: [  :uniq | 
	| noteName note creationDate initialModificationDate updatedModificationDate |
	noteName := 'testMock Modification Note'.

	note := uniq addNoteNamed: noteName.
	creationDate := note creationDate.
	initialModificationDate := note modificationDate.

	"Simulate some modification after a delay"
	Delay forSeconds: 1.
	note contents: 'testMock Modified content'.

	updatedModificationDate := note modificationDate.

	self assert: updatedModificationDate > initialModificationDate
		]
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNoteObjectsContainValidNotes [
	"Test that the note objects returned by the container are valid instances of Note class"

	sing safeDo: [  :uniq | 
	| noteName noteObject |
	noteName := self simplestNoteName.

	uniq addNoteNamed: noteName.

	noteObject := uniq noteNamed: noteName.
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
		uniq addNoteNamed: self simplestNoteName.
		self assert: uniq notesCount equals: 1.
		uniq removeNoteNamed: self simplestNoteName.
		self
			deny: uniq hasNotes
			description: 'It tests that now we haven''t any notes' ]
]

{ #category : 'test - tags' }
NTBasicTest >> testRemoveNoteFromTag [

    | tag note |

    tag := NTTag new.
    note := NTNoteObject new.
    tag addNote: note.
    tag removeNote: note.
    self deny: (tag notes includes: note).
]

{ #category : 'test - tags' }
NTBasicTest >> testRenameTag [
    | tag newName |

    tag := NTTag new.
    newName := 'New Tag Name'.
    tag tagName: newName.

    self assert: tag tagName equals: newName.
]

{ #category : 'test - tags' }
NTBasicTest >> testTagNote [

	sing safeDo: [ :uniq | 
		| noteName note noteTag |
	noteName := self simplestNoteName.
	uniq addNoteNamed: noteName.
	note := uniq noteNamed: noteName.
	noteTag := NTTag newNamed: 'music'.

	self assertEmpty: note tags.

	note addTag: noteTag.

	self assert: note tags anyOne equals: noteTag ]
]

{ #category : 'accessing' }
NTBasicTest >> threeNoteNames [

	^ { 
		self simplestNoteName , '1' .
		self simplestNoteName , '2' .
		self simplestNoteName , '3' 
		}.
]
