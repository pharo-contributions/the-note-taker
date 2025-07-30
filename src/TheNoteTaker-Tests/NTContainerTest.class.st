Class {
	#name : 'NTContainerTest',
	#superclass : 'TestCase',
	#instVars : [
		'noteTakerContainer'
	],
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTContainerTest class >> resources [
	^ { NTTestResource }
]

{ #category : 'running' }
NTContainerTest >> setUp [

	super setUp.
	noteTakerContainer := NTContainer new
]

{ #category : 'accessing' }
NTContainerTest >> simplestNoteName [

	^ 'testMock Note'
]

{ #category : 'tests - note' }
NTContainerTest >> testAddNewNote [

	self
		deny: noteTakerContainer hasNotes
		description: 'It tests that yet we haven''t any notes'.

	noteTakerContainer addNoteNamed: self simplestNoteName.

	self assert: noteTakerContainer notesCount equals: 1
]

{ #category : 'tests - note' }
NTContainerTest >> testAddNewNoteFromFileReference [

	| memory note |
	memory := FileSystem memory workingDirectory.
	note := NTNoteObject content: 'TEST'.
	note folderReference: memory.
	note save.

	noteTakerContainer addNoteFromFileReference: note fileReference.

	self assert: noteTakerContainer notesCount equals: 1
]

{ #category : 'tests - tags' }
NTContainerTest >> testAddNewTag [

	noteTakerContainer addTagNamed: 'Tag'.

	self assert: noteTakerContainer tags size equals: 1.
	self assert: noteTakerContainer tags first tagName equals: 'Tag'.
]

{ #category : 'tests - scenarios' }
NTContainerTest >> testAddingAndRemovingNotes [
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
NTContainerTest >> testAddingNotesWithSameName [
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

{ #category : 'tests - note' }
NTContainerTest >> testCreateNoteObject [

	| aNote |
	aNote := noteTakerContainer addNoteNamed: self simplestNoteName.
	self assert: aNote isNote
]

{ #category : 'tests - scenarios' }
NTContainerTest >> testMultipleNotesCreationAndAccess [
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
NTContainerTest >> testNoteDeletion [
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
NTContainerTest >> testNoteObjectsContainValidNotes [
	"Test that the note objects returned by the container are valid instances of Note class"

	| noteName noteObject note |
	noteName := self simplestNoteName.

	note := noteTakerContainer addNoteNamed: noteName.

	noteObject := noteTakerContainer noteNamed: note fileName.
	self assert: noteObject isNote
]

{ #category : 'tests - scenarios' }
NTContainerTest >> testNotesInitialization [
	"Test that the notes singleton is initialized correctly"

	self assertEmpty: noteTakerContainer notes
]

{ #category : 'tests - scenarios' }
NTContainerTest >> testNotesTitleMatching [
	
	noteTakerContainer addNoteNamed: 'Note'.
	noteTakerContainer addNoteNamed: 'Note2'.
	noteTakerContainer addNoteNamed: 'Test'.
	
	self
		assert: (noteTakerContainer notesTitleMatching: '') size
		equals: 3.

	self
		assert: (noteTakerContainer notesTitleMatching: 'Note') size
		equals: 2.

	self
		assert: (noteTakerContainer notesTitleMatching: 't') size
		equals: 3
]

{ #category : 'tests - scenarios' }
NTContainerTest >> testNotesWithTagSearch [

	| result note1 note2 note3 tag1 tag2 tag3 |
	note1 := noteTakerContainer addNoteNamed: 'note1'.
	note2 := noteTakerContainer addNoteNamed: 'note2'.
	note3 := noteTakerContainer addNoteNamed: 'note3'.

	tag1 := noteTakerContainer addTagNamed: 'tag1'.
	tag2 := noteTakerContainer addTagNamed: 'tag2'.
	tag3 := noteTakerContainer addTagNamed: 'tag3'.

	note1 addTag: tag1.
	note1 addTag: tag3.
	note2 addTag: tag2.

	result := noteTakerContainer
		          notes: noteTakerContainer notes
		          withTag: (noteTakerContainer tagNamed: 'test').
	self assert: result size equals: 0.

	result := noteTakerContainer
		          notes: noteTakerContainer notes
		          withTag: tag1.
	self assert: result size equals: 1
]

{ #category : 'tests - scenarios' }
NTContainerTest >> testNotesWithTagsSearch [

	| result note1 note2 note3 tag1 tag2 tag3 |
	note1 := noteTakerContainer addNoteNamed: 'note1'.
	note2 := noteTakerContainer addNoteNamed: 'note2'.
	note3 := noteTakerContainer addNoteNamed: 'note3'.

	tag1 := noteTakerContainer addTagNamed: 'tag1'.
	tag2 := noteTakerContainer addTagNamed: 'tag2'.
	tag3 := noteTakerContainer addTagNamed: 'tag3'.

	note1 addTag: tag1.
	note1 addTag: tag3.
	note2 addTag: tag2.
	
	result := noteTakerContainer
		          notes: noteTakerContainer notes
		          withTags: (OrderedCollection new
				           add: (noteTakerContainer tagNamed: 'test');
				           yourself).
	self assert: result size equals: 0.

	result := noteTakerContainer
		          notes: noteTakerContainer notes
		          withTags: (OrderedCollection new
				           add: tag1;
				           yourself).
	self assert: result size equals: 1
]

{ #category : 'tests - note' }
NTContainerTest >> testRemoveNote [

	| note |
	note := noteTakerContainer addNoteNamed: self simplestNoteName.
	self assert: noteTakerContainer notesCount equals: 1.
	noteTakerContainer removeNoteNamed: note fileName.
	self
		deny: noteTakerContainer hasNotes
		description: 'It tests that now we haven''t any notes' 
]

{ #category : 'tests - tags' }
NTContainerTest >> testRemoveTag [

	self assert: noteTakerContainer tags size equals: 0.
	
	noteTakerContainer addTagNamed: 'Tag'.
	self assert: noteTakerContainer tags size equals: 1.
	
	noteTakerContainer removeTag: noteTakerContainer tags first.
	self assert: noteTakerContainer tags size equals: 0.
]

{ #category : 'tests - tags' }
NTContainerTest >> testRemoveTagNamed [

	self assert: noteTakerContainer tags size equals: 0.

	noteTakerContainer addTagNamed: 'Tag'.
	self assert: noteTakerContainer tags size equals: 1.

	noteTakerContainer removeTagNamed: 'Tag'.
	self assert: noteTakerContainer tags size equals: 0
]

{ #category : 'tests - tags' }
NTContainerTest >> testTagNamed [

	noteTakerContainer addTagNamed: 'Tag'.
	noteTakerContainer addTagNamed: 'Tag2'.
	noteTakerContainer addTagNamed: 'Tag3'.

	self
		assert: (noteTakerContainer tagNamed: 'Tag')
		equals: noteTakerContainer tags first.

	self
		assert: (noteTakerContainer tagNamed: 'Tag3')
		equals: noteTakerContainer tags third.
]

{ #category : 'tests - tags' }
NTContainerTest >> testTagNamedCreateTagWhenDoesntExist [

	self assert: noteTakerContainer tags size equals: 0.
	
	self
		assert: (noteTakerContainer tagNamed: 'Tag')
		equals: noteTakerContainer tags first.
		
	self assert: noteTakerContainer tags size equals: 1.

	self
		assert: (noteTakerContainer tagNamed: 'Tag3')
		equals: noteTakerContainer tags second.
		
self assert: noteTakerContainer tags size equals: 2.
]

{ #category : 'tests - tags' }
NTContainerTest >> testTagsMatchingWithNotes [

	| tag1 tag2 note1 note2 note3 noteCollection |
	tag1 := NTTag newNamed: 'Tag1'.
	tag2 := NTTag newNamed: 'Tag2'.

	note1 := NTNoteObject content: 'note1'.
	note1 addTag: tag1.
	note2 := NTNoteObject content: 'note2'.
	note2 addTag: tag1.
	note3 := NTNoteObject content: 'note3'.
	note3 addTag: tag2.

	noteCollection := OrderedCollection new
		                  add: note1;
		                  add: note2;
		                  add: note3;
		                  yourself.

	self
		assert: (noteTakerContainer
				 notes: noteCollection
				 withTags: (OrderedCollection new
						  add: tag1;
						  yourself)) size
		equals: 2.

	self
		assert: (noteTakerContainer
				 notes: noteCollection
				 withTags: (OrderedCollection new
						  add: tag2;
						  yourself)) size
		equals: 1.

	self
		assert: (noteTakerContainer
				 notes: noteCollection
				 withTags: (OrderedCollection new
						  add: (NTTag newNamed: 'Test');
						  yourself)) size
		equals: 0
]

{ #category : 'tests - tags' }
NTContainerTest >> testTagsNamedMatching [

	noteTakerContainer addTagNamed: 'Tag'.
	noteTakerContainer addTagNamed: 'Tag2'.
	noteTakerContainer addTagNamed: 'Tag3'.

	self
		assert: (noteTakerContainer tagsNameMatching: 'Tag') size
		equals: 3.

	self
		assert: (noteTakerContainer tagsNameMatching: '3') size
		equals: 1
]

{ #category : 'accessing' }
NTContainerTest >> threeNoteNames [

	^ { 
		self simplestNoteName , '1' .
		self simplestNoteName , '2' .
		self simplestNoteName , '3' 
		}.
]
