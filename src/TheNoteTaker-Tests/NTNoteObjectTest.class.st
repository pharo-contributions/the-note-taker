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
NTNoteObjectTest >> generateMetaDataWithTitle: filename modificationDate: modificationDate [

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
NTNoteObjectTest >> testLoadNoteWithMetadata [

	| note noteFile metadata |
	
	self skip.
	
	noteFile := memoryFS / '2024-06-12_newNote.md'. 
	metadata := self generateMetaDataWithTitle: 'Ceci est un test' modificationDate: '2024-01-01' asDateAndTime.
	noteFile writeStreamDo: [ : stream | stream nextPutAll: metadata, String crlf, String crlf, 'This is just a new note' ].
	
	note := NTNoteObject newFromFileReference: noteFile.
	
	self assert: note exists.
	self assert: note contents equals: 'This is just a new note'.
	self assert: note fileName equals: '2024-06-12_newNote.md'.
	self assert: note title equals: 'This is just a new note'.
]

{ #category : 'tests' }
NTNoteObjectTest >> testLoadNoteWithoutMetadata [

	| note noteFile |
	
	noteFile := memoryFS / '2024-06-12_newNote.md'. 
	noteFile writeStreamDo: [ : stream | stream nextPutAll: 'This is just a new note' ].
	
	note := NTNoteObject newFromFileReference: noteFile.
	
	self assert: note exists.
	self assert: note contents equals: 'This is just a new note'.
	self assert: note fileName equals: '2024-06-12_newNote.md'.
	self assert: note title equals: 'This is just a new note'.
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
NTNoteObjectTest >> testSaveExistingFileWithDifferentTitle [

	| note modificationDate metadata finalContents fileName |
	
	note := NTNoteObject named: 'Test' contents: 'Ceci est un test'.
	modificationDate := note modificationDate.
	note folderReference: memoryFS.
	note save.
	fileName := note fileName.
	note contents: 'I change the title'.
	note save.
	
	self denyEmpty: note fileReference contents.
	
	metadata := self generateMetaDataWithTitle: 'I change the title' modificationDate: note modificationDate.
	finalContents :=  metadata, String crlf, String crlf, 'I change the title'.
	
	self assert: note fileReference contents equals: finalContents.
	self assert: note fileName equals: fileName.
]

{ #category : 'tests' }
NTNoteObjectTest >> testSaveNote [
	
	| note modificationDate metadata finalContents |
	
	note := NTNoteObject named: 'Test' contents: 'Ceci est un test'.
	modificationDate := note modificationDate.
	note folderReference: memoryFS.
	note save.
	
	self denyEmpty: note fileReference contents.
	
	metadata := self generateMetaDataWithTitle: 'Ceci est un test' modificationDate: note modificationDate.
	finalContents :=  metadata, String crlf, String crlf, 'Ceci est un test'.
	
	self assert: note fileReference contents equals: finalContents
]

{ #category : 'tests' }
NTNoteObjectTest >> testTitleIsFirstLineOfContents [

	| note1 note2 note3 |
	
	note1 := NTNoteObject named: 'Test1' contents: 'test with only one line'.
	note2 := NTNoteObject named: 'Test2' contents: 'test with two line', String crlf, 'Second Line'.
	note3 := NTNoteObject named: 'Test3' contents: ''.	
	
	self assert: note1 title equals: 'test with only one line';
		assert: note2 title equals: 'test with two line';
		assert: note3 title equals: ''.
]
