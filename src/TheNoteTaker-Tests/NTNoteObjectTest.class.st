Class {
	#name : 'NTNoteObjectTest',
	#superclass : 'NTBasicTest',
	#instVars : [
		'memoryFS'
	],
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTNoteObjectTest >> generateMetaDataWithFileName: filename modificationDate: modificationDate [

^ '{
"lastModificationDate" : "', modificationDate asDate yyyymmdd asString ,'",
"author" : "toto for now",
"title" : "',filename ,'"
}'
]

{ #category : 'running' }
NTNoteObjectTest >> setUp [
	
	super setUp.
	memoryFS := FileSystem memory workingDirectory.
]

{ #category : 'tests' }
NTNoteObjectTest >> testLoadNote [

	self skip.
	self assert: false.
]

{ #category : 'tests' }
NTNoteObjectTest >> testNoteCreationAndModificationDates [
	"Test that creation and modification dates are correctly set for notes"

	| noteName note creationDate modificationDate |
	noteName := self simplestNoteName.

	note := NTNoteObject named: noteName.
	creationDate := note creationDate.
	modificationDate := note modificationDate.

	self assert: creationDate notNil.
	self assert: modificationDate notNil.
	self assert: creationDate equals: modificationDate

]

{ #category : 'tests' }
NTNoteObjectTest >> testNoteModificationDoesNotUpdateCreationDate [
	"Test that modifying a note does not update the creation date"

	| noteName note creationDate initialModificationDate updatedCreationDate |
	noteName := 'testMock Creation Date Note'.

	note := NTNoteObject named: noteName.
	creationDate := note creationDate.
	initialModificationDate := note modificationDate.

	"Simulate some modification after a delay"
	Delay forSeconds: 1.
	note contents: 'testMock Modified content'.

	updatedCreationDate := note creationDate.

	self assert: updatedCreationDate equals: creationDate
]

{ #category : 'tests' }
NTNoteObjectTest >> testNoteModificationUpdatesModificationDate [
	"Test that modifying a note updates the modification date"
	
	| noteName note creationDate initialModificationDate updatedModificationDate |
	noteName := 'testMock Modification Note'.

	note := NTNoteObject named: noteName.
	creationDate := note creationDate.
	initialModificationDate := note modificationDate.

	"Simulate some modification after a delay"
	(Delay forSeconds: 1) wait.
	note contents: 'testMock Modified content'.

	updatedModificationDate := note modificationDate.

	self assert: updatedModificationDate > initialModificationDate
]

{ #category : 'tests' }
NTNoteObjectTest >> testSaveNote [
	
	| note modificationDate metadata finalContents |
	
	note := NTNoteObject named: 'Test' contents: 'Ceci est un test'.
	modificationDate := note modificationDate.
	note folderReference: memoryFS.
	note save.
	
	self denyEmpty: note fileReference contents.
	
	metadata := self generateMetaDataWithFileName: 'Ceci est un ' modificationDate: note modificationDate.
	finalContents :=  metadata, String crlf, String crlf, 'Ceci est un test'.
	
	self assert: note fileReference contents equals: finalContents
]
