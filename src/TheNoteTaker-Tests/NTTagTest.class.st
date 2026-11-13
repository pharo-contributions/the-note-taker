Class {
	#name : 'NTTagTest',
	#superclass : 'TestCase',
	#instVars : [
		'tag',
		'note'
	],
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'running' }
NTTagTest >> setUp [

	super setUp.
	tag := NTTag newNamed: 'tag'.
	note := NTNote new
]

{ #category : 'tests' }
NTTagTest >> testAddNoteToTag [

	tag addNote: note.
	self assert: (tag notes includes: note).
	self assert: tag notes size equals: 1
]

{ #category : 'tests' }
NTTagTest >> testAddNoteTwoTimesToTag [

	tag addNote: note.
	tag addNote: note.
	self assert: (tag notes includes: note).
	self assert: tag notes size equals: 1
]

{ #category : 'tests' }
NTTagTest >> testAddTagInNoteAddNoteInTag [

	self assertEmpty: note tags.
	note addTag: tag.
	self assert: tag notes anyOne equals: note
]

{ #category : 'tests' }
NTTagTest >> testAddTwoDifferentNote [

	| otherNote |
	otherNote := NTNote new.
	tag addNote: note.
	tag addNote: otherNote.

	self assert: (tag notes includes: note).
	self assert: (tag notes includes: otherNote).
	self assert: tag notes size equals: 2
]

{ #category : 'tests' }
NTTagTest >> testHasNote [

	self deny: (tag hasNote: note).
	tag addNote: note.
	self assert: (tag hasNote: note).
]

{ #category : 'tests' }
NTTagTest >> testRemoveNoteFromTag [

	tag addNote: note.
	tag removeNote: note.
	self deny: (tag notes includes: note)
]

{ #category : 'tests' }
NTTagTest >> testRemoveTagFromNote [

	tag addNote: note.
	note removeTag: tag.

	self assertEmpty: tag notes
]

{ #category : 'tests' }
NTTagTest >> testRenameTag [

	| newName |
	newName := 'New Tag Name'.
	tag tagName: newName.

	self assert: tag tagName equals: newName
]

{ #category : 'tests - name' }
NTTagTest >> testTagNameDropsCommas [
	"Commas separate the tags in the metadata of a note file"

	self assert: (NTTag newNamed: 'to,do') tagName equals: 'todo'
]

{ #category : 'tests - name' }
NTTagTest >> testTagNameDropsQuotesAndBackslashes [
	"They break the metadata of a note file (see the Microdown backlog)"

	self assert: (NTTag newNamed: 'say "hi" back\slash') tagName equals: 'say hi backslash'
]

{ #category : 'tests - name' }
NTTagTest >> testTagNameIsTrimmed [

	self assert: (NTTag newNamed: '  spec ') tagName equals: 'spec'
]

{ #category : 'tests - name' }
NTTagTest >> testTagNameKeepsOtherCharacters [

	self assert: (NTTag newNamed: 'Shopping list café #1') tagName equals: 'Shopping list café #1'
]
