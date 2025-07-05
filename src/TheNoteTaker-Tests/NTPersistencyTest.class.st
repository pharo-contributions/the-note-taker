Class {
	#name : 'NTPersistencyTest',
	#superclass : 'NTContainerTest',
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'running' }
NTPersistencyTest >> resource [

	^ NTTestResource current
]

{ #category : 'running' }
NTPersistencyTest >> testCreateNoteDoesNotSerialize [

	| sampleNote |
	sampleNote := NTNoteObject new.
	
	self 
		deny: sampleNote exists
		description: 'It test that a Note object is not automatically persisted'.
	
	sampleNote title: self simplestNoteName.
	self 
		deny: sampleNote exists
		description: 'It test that title assignment does not persist the note'.

	
]

{ #category : 'running' }
NTPersistencyTest >> testCreatingANoteDoesNotAddItToSingleton [

	| sampleNote |
	self deny: noteTakerContainer hasNotes.
	sampleNote := NTNoteObject new.
	self deny: noteTakerContainer hasNotes
]

{ #category : 'running' }
NTPersistencyTest >> testNotesNotEmpty [

	self denyEmpty: self resource stonNotes.
	
]
