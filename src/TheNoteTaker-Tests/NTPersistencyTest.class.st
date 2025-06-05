Class {
	#name : 'NTPersistencyTest',
	#superclass : 'NTBasicTest',
	#instVars : [
		'memoryRoot'
	],
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'running' }
NTPersistencyTest >> setUp [

	super setUp.
	memoryRoot := FileSystem memory root.
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

	NTSingleton safeDo: [ :uniq |
	| sampleNote |
		self deny: uniq hasNotes. 
		sampleNote := NTNoteObject new.
		self deny: uniq hasNotes. 
		]
]

{ #category : 'running' }
NTPersistencyTest >> testNotesNotEmpty [

	self denyEmpty: self resource stonNotes.
	
]
