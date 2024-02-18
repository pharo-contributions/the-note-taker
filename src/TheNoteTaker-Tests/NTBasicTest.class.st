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
	noteFacade := NoteTakerFacade new.
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

{ #category : 'tests' }
NTBasicTest >> testCreateNoteObject [

	| aNote |
	aNote := noteFacade newNoteNamed: 'first note'.
	self assert: aNote isNote.
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
