Class {
	#name : 'NTBasicTest',
	#superclass : 'TestCase',
	#instVars : [
		'notesContainer'
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
	notesContainer := NTSingleton uniqueInstance.
]

{ #category : 'accessing' }
NTBasicTest >> simplestNoteName [

	^ 'testMock Note'
]

{ #category : 'running' }
NTBasicTest >> tearDown [

	notesContainer removeNotesSuchThat: [ : n | n title beginsWith: 'testMock' ].
	super tearDown.
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

	self 
		deny: notesContainer hasNotes
		description: 'It tests that yet we haven''t any notes'.

	notesContainer addNoteNamed: self simplestNoteName.

	self 
		assert: notesContainer notesCount 
		equals: 1.
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
    | noteName notes |

    noteName := self simplestNoteName.
    
    notesContainer addNoteNamed: noteName.
    self assert: (notesContainer hasNoteNamed: noteName).
    
    notes := notesContainer notes.
    self assert: notes size equals: 1.
    
    notesContainer removeNoteNamed: noteName.
    self deny: (notesContainer hasNoteNamed: noteName).
    self assertEmpty: notesContainer notes.
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testAddingNotesWithSameName [
    "Test adding notes with the same name"
    | noteName notes |

    noteName := self simplestNoteName.
    
    notesContainer addNoteNamed: noteName.
    notesContainer addNoteNamed: noteName.
    
    notes := notesContainer notes.
    
	"Two notes should be added"
    self assert: notes size equals: 2.
    self assert: (notesContainer hasNoteNamed: self simplestNoteName).
    self 
		assert: (notesContainer noteNamed: self simplestNoteName) isNote
		description: 'Check if the note is an instance of Note class'

]

{ #category : 'tests' }
NTBasicTest >> testCreateNoteObject [

	| aNote |
	aNote := notesContainer newNoteNamed: self simplestNoteName.
	self assert: aNote isNote.
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

	| noteNames notes |

	noteNames := self threeNoteNames.
    
	noteNames do: [ :name | notesContainer addNoteNamed: name ].
	notes := notesContainer notes.
    
	self 
		assert: notes size 
		equals: noteNames size.
	noteNames do: [ :name | self assert: (notesContainer hasNoteNamed: name) ].
]

{ #category : 'tests - dates' }
NTBasicTest >> testNoteCreationAndModificationDates [
    "Test that creation and modification dates are correctly set for notes"
    | noteName note creationDate modificationDate |

    noteName := self simplestNoteName.
    
    note := notesContainer addNoteNamed: noteName.
    creationDate := note creationDate.
    modificationDate := note modificationDate.
    
    self assert: creationDate notNil.
    self assert: modificationDate notNil.
    self assert: creationDate equals: modificationDate.
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNoteDeletion [
    "Test creating notes and deleting one of them"
    | noteNames notes secondNoteName |

	secondNoteName := self simplestNoteName , '2'.
	noteNames := self threeNoteNames.
    
	noteNames do: [ :name | notesContainer addNoteNamed: name ].
    
	notesContainer removeNoteNamed: secondNoteName.
    
	notes := notesContainer notes.
    
	self assert: notes size equals: noteNames size - 1.
	self deny: (notesContainer hasNoteNamed: secondNoteName).

]

{ #category : 'tests - dates' }
NTBasicTest >> testNoteModificationDoesNotUpdateCreationDate [
    "Test that modifying a note does not update the creation date"
    | noteName note creationDate initialModificationDate updatedCreationDate |

    noteName := 'testMock Creation Date Note'.
    
    note := notesContainer addNoteNamed: noteName.
    creationDate := note creationDate.
    initialModificationDate := note modificationDate.
    
    "Simulate some modification after a delay"
    Delay forSeconds: 1.
    note contents: 'testMock Modified content'.
    
    updatedCreationDate := note creationDate.
    
    self assert: updatedCreationDate equals: creationDate.

]

{ #category : 'tests - dates' }
NTBasicTest >> testNoteModificationUpdatesModificationDate [
    "Test that modifying a note updates the modification date"
    | noteName note creationDate initialModificationDate updatedModificationDate |

    noteName := 'testMock Modification Note'.
    
    note := notesContainer addNoteNamed: noteName.
    creationDate := note creationDate.
    initialModificationDate := note modificationDate.
    
    "Simulate some modification after a delay"
    Delay forSeconds: 1.
    note contents: 'testMock Modified content'.
    
    updatedModificationDate := note modificationDate.
    
    self assert: updatedModificationDate > initialModificationDate.
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNoteObjectsContainValidNotes [
    "Test that the note objects returned by the container are valid instances of Note class"

    | noteName noteObject |
    noteName := self simplestNoteName.
    
    notesContainer addNoteNamed: noteName.
    
    noteObject := notesContainer noteNamed: noteName.
    self assert: noteObject isNote
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNotesInitialization [
    "Test that the notes singleton is initialized correctly"

    self assertEmpty: notesContainer notes.
]

{ #category : 'tests' }
NTBasicTest >> testRemoveNote [

	notesContainer addNoteNamed: self simplestNoteName.
	self 
		assert: notesContainer notesCount 
		equals: 1.
	notesContainer removeNoteNamed: self simplestNoteName.
	self 
		deny: notesContainer hasNotes
		description: 'It tests that now we haven''t any notes'.
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

{ #category : 'tests - scenarios' }
NTBasicTest >> testSingletonInstanceIsSame [
    "Test that the uniqueInstance method returns the same instance of the NotesContainer singleton"
    | notesContainer1 notesContainer2 |

    notesContainer1 := NTSingleton uniqueInstance.
    notesContainer2 := NTSingleton uniqueInstance.

    self 
		assert: notesContainer1 
		identicalTo: notesContainer2.
]

{ #category : 'test - tags' }
NTBasicTest >> testTagNote [

	| noteName note noteTag |

	noteName := self simplestNoteName.
	notesContainer addNoteNamed: noteName.
	note := notesContainer noteNamed: noteName.
	noteTag := NTTag newNamed: 'music'.
	
	self assertEmpty: note tags.
	
	note addTag: noteTag.
	
	self 
		assert: note tags anyOne
		equals: noteTag.
]

{ #category : 'accessing' }
NTBasicTest >> threeNoteNames [

	^ { 
		self simplestNoteName , '1' .
		self simplestNoteName , '2' .
		self simplestNoteName , '3' 
		}.
]
