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
NTPersistencyTest >> testNotesInJSONFormat [

	self
		denyEmpty: self resource stonNotes
		
		
]
