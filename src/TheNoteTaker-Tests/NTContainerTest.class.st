Class {
	#name : 'NTContainerTest',
	#superclass : 'TestCase',
	#instVars : [
		'noteTakerContainer',
		'ressources'
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
	noteTakerContainer := NTContainer new.

	ressources := NTUITestResource new.
]

{ #category : 'tests - note' }
NTContainerTest >> testAddNewNote [

	noteTakerContainer addNote: (NTNote content: 'Test').
	self assert: noteTakerContainer notesCount equals: 1
]

{ #category : 'tests - note' }
NTContainerTest >> testAddNewNoteByName [

	noteTakerContainer addNoteNamed: 'Test'.
	self assert: noteTakerContainer notesCount equals: 1
]

{ #category : 'tests - note' }
NTContainerTest >> testAddNewNoteFromFileReference [

	| memory note |

	memory := FileSystem memory workingDirectory.
	note := NTNote content: 'TEST'.
	note folderReference: memory.
	note save.

	noteTakerContainer addNoteFromFileReference: note fileReference.

	self assert: noteTakerContainer notesCount equals: 1
]

{ #category : 'tests - tags' }
NTContainerTest >> testAddNewTag [

	noteTakerContainer addTagNamed: 'Tag'.
	self assert: noteTakerContainer tags size equals: 1
]

{ #category : 'tests - note' }
NTContainerTest >> testAddingNotesWithSameName [
	"Test adding notes with the same name"

	| noteName notes |
	noteName := 'Test'.

	noteName := (noteTakerContainer addNoteNamed: noteName) fileName.
	noteTakerContainer addNoteNamed: noteName.

	notes := noteTakerContainer notes.

	"Two notes should be added"
	self assert: notes size equals: 2
]

{ #category : 'tests - scenarios' }
NTContainerTest >> testNotesTitleMatching [

	ressources addingNotesAndTagsTo: noteTakerContainer.

	self
		assert: (noteTakerContainer notesTitleMatching: '') size
		equals: 3.

	self
		assert: (noteTakerContainer notesTitleMatching: 'note') size
		equals: 3.

	self
		assert: (noteTakerContainer notesTitleMatching: 'ZZZ') size
		equals: 0
]

{ #category : 'tests - scenarios' }
NTContainerTest >> testNotesWithTags [

	| result |
	ressources addingNotesAndTagsTo: noteTakerContainer.

	result := noteTakerContainer
		          notes: noteTakerContainer notes
		          withTags: (OrderedCollection new
				           add: (noteTakerContainer ensureTagNamed: 'test');
				           yourself).
	self assert: result size equals: 0.

	result := noteTakerContainer
		          notes: noteTakerContainer notes
		          withTags: (OrderedCollection new
				           add: ressources getTag1;
				           yourself).
	self assert: result size equals: 1
]

{ #category : 'tests - note' }
NTContainerTest >> testRemoveNotes [

	ressources addingNotesAndTagsTo: noteTakerContainer.
	
	self assert: noteTakerContainer notesCount equals: 3.
	noteTakerContainer removeNotes: (OrderedCollection new
			 add: ressources getNote1;
			 add: ressources getNote2;
			 yourself).
	self assert: noteTakerContainer notesCount equals: 1
]

{ #category : 'tests - tags' }
NTContainerTest >> testTagNamed [

	ressources addingNotesAndTagsTo: noteTakerContainer.

	self
		assert: (noteTakerContainer ensureTagNamed: 'tag1')
		equals: ressources getTag1.

	self
		assert: (noteTakerContainer ensureTagNamed: 'tag3')
		equals: ressources getTag3
]

{ #category : 'tests - tags' }
NTContainerTest >> testTagNamedCreateTagWhenDoesntExist [

	noteTakerContainer ensureTagNamed: 'Tag'.

	self assert: noteTakerContainer tags size equals: 1.

	noteTakerContainer ensureTagNamed: 'Tag3'.

	self assert: noteTakerContainer tags size equals: 2
]

{ #category : 'tests - tags' }
NTContainerTest >> testTagsNameMatching [

	ressources addingNotesAndTagsTo: noteTakerContainer.

	self
		assert: (noteTakerContainer tagsNameMatching: 'tag') size
		equals: 3.

	self
		assert: (noteTakerContainer tagsNameMatching: '3') size
		equals: 1
]
