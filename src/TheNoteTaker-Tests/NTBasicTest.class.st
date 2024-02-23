Class {
	#name : 'NTBasicTest',
	#superclass : 'TestCase',
	#instVars : [
		'noteFacade'
	],
	#category : 'TheNoteTaker-Tests',
	#package : 'TheNoteTaker-Tests'
}

{ #category : 'running' }
NTBasicTest >> setUp [

	super setUp.
	noteFacade := NTSingleton new.
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
    tag renameTagTo: tagName.

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
		deny: noteFacade hasNotes
		description: 'It tests that yet we haven''t any notes'.

	noteFacade addNoteNamed: (noteFacade newNoteNamed: 'first note').

	self 
		assert: noteFacade notesCount 
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
    | notesContainer noteName notes |

    notesContainer := NTSingleton uniqueInstance.
    noteName := 'Important Note'.
    
    notesContainer addNoteNamed: noteName.
    self assert: (notesContainer hasNoteNamed: noteName).
    
    notes := notesContainer noteObjects.
    self assert: notes size equals: 1.
    
    notesContainer removeNoteNamed: noteName.
    self deny: (notesContainer hasNoteNamed: noteName).
    self assertEmpty: notesContainer noteObjects.
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testAddingNotesWithSameName [
    "Test adding notes with the same name"
    | notesContainer noteName notes |

    notesContainer := NTSingleton uniqueInstance.
    noteName := 'Note'.
    
    notesContainer addNoteNamed: noteName.
    notesContainer addNoteNamed: noteName.
    
    notes := notesContainer noteObjects.
    
    self assert: notes size equals: 2. "Two notes should be added"
    self assert: (notesContainer hasNoteNamed: 'Note').
    self 
		assert: (notesContainer noteNamed: 'Note') isNote
		description: 'Check if the note is an instance of Note class'

]

{ #category : 'tests' }
NTBasicTest >> testCreateNoteObject [

	| aNote |
	aNote := noteFacade newNoteNamed: 'first note'.
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

    | notesContainer noteNames notes |
    notesContainer := NTSingleton uniqueInstance.
    noteNames := #('Note 1' 'Note 2' 'Note 3').
    
    noteNames do: [ :name | notesContainer addNoteNamed: name ].
	notes := notesContainer noteObjects.
    
    self 
		assert: notes size 
		equals: noteNames size.
    noteNames do: [ :name | self assert: (notesContainer hasNoteNamed: name) ].
]

{ #category : 'tests - dates' }
NTBasicTest >> testNoteCreationAndModificationDates [
    "Test that creation and modification dates are correctly set for notes"
    | notesContainer noteName note creationDate modificationDate |

    notesContainer := NTSingleton uniqueInstance.
    noteName := 'Date Note'.
    
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
    | notesContainer noteNames notes |

    notesContainer := NTSingleton uniqueInstance.
    noteNames := #('Note 1' 'Note 2' 'Note 3').
    
    noteNames do: [ :name | notesContainer addNoteNamed: name ].
    
    notesContainer removeNoteNamed: 'Note 2'.
    
    notes := notesContainer noteObjects.
    
    self assert: notes size equals: noteNames size - 1.
    self deny: (notesContainer hasNoteNamed: 'Note 2').

]

{ #category : 'tests - dates' }
NTBasicTest >> testNoteModificationDoesNotUpdateCreationDate [
    "Test that modifying a note does not update the creation date"
    | notesContainer noteName note creationDate initialModificationDate updatedCreationDate |

    notesContainer := NTSingleton uniqueInstance.
    noteName := 'Creation Date Note'.
    
    note := notesContainer addNoteNamed: noteName.
    creationDate := note creationDate.
    initialModificationDate := note modificationDate.
    
    "Simulate some modification after a delay"
    Delay forSeconds: 1.
    note contents: 'Modified content'.
    
    updatedCreationDate := note creationDate.
    
    self assert: updatedCreationDate equals: creationDate.

]

{ #category : 'tests - dates' }
NTBasicTest >> testNoteModificationUpdatesModificationDate [
    "Test that modifying a note updates the modification date"
    | notesContainer noteName note creationDate initialModificationDate updatedModificationDate |

    notesContainer := NTSingleton uniqueInstance.
    noteName := 'Modification Note'.
    
    note := notesContainer addNoteNamed: noteName.
    creationDate := note creationDate.
    initialModificationDate := note modificationDate.
    
    "Simulate some modification after a delay"
    Delay forSeconds: 1.
    note contents: 'Modified content'.
    
    updatedModificationDate := note modificationDate.
    
    self assert: updatedModificationDate > initialModificationDate.
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNoteObjectsContainValidNotes [
    "Test that the note objects returned by the container are valid instances of Note class"

    | notesContainer noteName noteObject |

    notesContainer := NTSingleton uniqueInstance.
    noteName := 'Sample Note'.
    
    notesContainer addNoteNamed: noteName.
    
    noteObject := notesContainer noteNamed: noteName.
    self assert: noteObject isNote
]

{ #category : 'tests - scenarios' }
NTBasicTest >> testNotesInitialization [
    "Test that the notes singleton is initialized correctly"
    | notesContainer |

    notesContainer := NTSingleton uniqueInstance.
    self assertEmpty: notesContainer noteObjects.
]

{ #category : 'tests' }
NTBasicTest >> testRemoveNote [

	| noteName |
	noteName :=  'first note'.
	noteFacade addNoteNamed: noteName.
	self 
		assert: noteFacade notesCount 
		equals: 1.
	noteFacade removeNoteNamed: noteName.
	self 
		deny: noteFacade hasNotes
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
    tag renameTagTo: newName.

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

	noteName :=  'first note'.
	noteFacade addNoteNamed: noteName.
	note := noteFacade noteNamed: noteName.
	noteTag := NTTag newNamed: 'music'.
	
	self assertEmpty: note tags.
	
	note addTag: #('music').
	
	self 
		assert: note tags anyOne
		equals: noteTag.
]
