Class {
	#name : 'NTNoteObjectTest',
	#superclass : 'TestCase',
	#instVars : [
		'memoryFS',
		'note',
		'tag1',
		'tag2'
	],
	#category : 'TheNoteTaker-Tests-Core',
	#package : 'TheNoteTaker-Tests',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTNoteObjectTest >> generateMetaDataCreationDateLine: creationDate [
	
	^ '"creationDate" : "',creationDate asString,'"'
]

{ #category : 'accessing' }
NTNoteObjectTest >> generateMetaDataModificationDateLine: modificationDate [
	
	^ '"lastModificationDate" : "',modificationDate asString,'"'
]

{ #category : 'accessing' }
NTNoteObjectTest >> generateMetaDataTagsCollectionLine: aTagCollection [

	| stream |
	stream := WriteStream with: '"tags" : "'.
	stream nextPutAll: (((aTagCollection collect: [ :each | each tagName ]) asArray sorted: [ :a :b | a < b ]) joinUsing:','). 
	stream nextPutAll: '"'.
	^ stream contents
]

{ #category : 'accessing' }
NTNoteObjectTest >> generateMetaDataWithCreationDate: creationDate modificationDate: modificationDate [

	^ '{' , String cr
	  , (self generateMetaDataModificationDateLine: modificationDate)
	  , ',' , String cr
	  , (self generateMetaDataCreationDateLine: creationDate) , String cr
	  , '}'
]

{ #category : 'accessing' }
NTNoteObjectTest >> generateMetaDataWithCreationDate: creationDate modificationDate: modificationDate tags: aTagCollection [

	^ '{' , String cr
	  , (self generateMetaDataModificationDateLine: modificationDate)
	  , ',' , String cr
	  , (self generateMetaDataCreationDateLine: creationDate) , ','
	  , String cr
	  , (self generateMetaDataTagsCollectionLine: aTagCollection)
	  , String cr , '}'
]

{ #category : 'running' }
NTNoteObjectTest >> setUp [

	super setUp.
	memoryFS := FileSystem memory workingDirectory.
	note := NTNote new.
	tag1 := NTTag newNamed: 'tag1'.
	tag2 := NTTag newNamed: 'tag2'.
]

{ #category : 'tests - saving' }
NTNoteObjectTest >> testAddSameTagTwice [

	note
		addTag: tag1;
		addTag: tag1.

	self assert: note tags size equals: 1
]

{ #category : 'tests - saving' }
NTNoteObjectTest >> testAddTwoTagsWithSameName [

	note
		addTag: tag1;
		addTag: (NTTag newNamed: tag1 tagName).

	self assert: note tags size equals: 1
]

{ #category : 'tests' }
NTNoteObjectTest >> testFileName [

	self flag: #ToRename.
	note creationDate: '2024-01-01' asDateAndTime.
	
	note fileName: 'Test'.
	self assert: note fileName equals: '2024-01-01_Test.md'.

	note fileName: '[!Te@st}='.
	self assert: note fileName equals: '2024-01-01_Test.md'.
	
	note fileName: 'Test With Space'.
	self assert: note fileName equals: '2024-01-01_TestWithSpace.md'
]

{ #category : 'tests -generate' }
NTNoteObjectTest >> testGenerateMetaDataElementsWithTags [

	| note creationDate modificationDate tag1 tag2 |
	note := NTNote content: 'Ceci est un test'.
	creationDate := '2025-01-01' asDateAndTime.
	modificationDate := '2025-01-02' asDateAndTime.
	note creationDate: creationDate.
	note modificationDate: modificationDate.

	tag1 := NTTag newNamed: 'tag1'.
	tag2 := NTTag newNamed: 'tag2'.
	tag1 addNote: note.
	tag2 addNote: note.

	note folderReference: memoryFS.

	self assert: note generateMetaDataElements equals: (self
			 generateMetaDataWithCreationDate: creationDate
			 modificationDate: modificationDate
			 tags: note tags)
]

{ #category : 'tests -generate' }
NTNoteObjectTest >> testGenerateMetaDataElementsWithoutTags [

	| creationDate modificationDate |
	note contents: 'Ceci est un test'.
	creationDate := '2025-01-01' asDateAndTime.
	modificationDate := '2025-01-02' asDateAndTime.
	note creationDate: creationDate.
	note modificationDate: modificationDate.

	note folderReference: memoryFS.

	self assert: note generateMetaDataElements equals: (self
			 generateMetaDataWithCreationDate: creationDate
			 modificationDate: modificationDate)
]

{ #category : 'tests -generate' }
NTNoteObjectTest >> testGenerateTitle [

	| note1 note2 note3 |
	note1 := NTNote content: 'test with only one line'.
	note2 := NTNote content:
		         'test with two line' , String crlf , 'Second Line'.
	note3 := NTNote content: ''.

	self
		assert: note1 title equals: 'test with only one line';
		assert: note2 title equals: 'test with two line';
		assert: note3 title equals: 'unnamed'
]

{ #category : 'tests' }
NTNoteObjectTest >> testIsDirty [

	| noteFile |
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	noteFile writeStreamDo: [ :stream |
		stream nextPutAll: 'This is just a new note' ].

	note := NTNote newFromFileReference: noteFile.
	self deny: note isDirty.

	note contents: 'Change the contents'.
	self assert: note isDirty.

	note save.
	self deny: note isDirty
]

{ #category : 'tests - loading' }
NTNoteObjectTest >> testLoadNoteWithAllMetadata [

	| noteFile metadata tags |
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	tags := OrderedCollection new
		        add: tag1;
		        add: tag2;
		        yourself.
	metadata := self
		            generateMetaDataWithCreationDate:
		            '2025-01-01' asDateAndTime
		            modificationDate: '2024-01-01' asDateAndTime
		            tags: tags.
	noteFile writeStreamDo: [ :stream |
			stream
				nextPutAll: metadata;
				nextPutAll: String crlf;
				nextPutAll: String crlf;
				nextPutAll: 'This is just a new note' ].

	note := NTNote newFromFileReference: noteFile.

	self assert: note exists.
	self assert: note contents equals: 'This is just a new note'.
	self assert: note fileName equals: '2024-06-12_newNote.md'.
	self assert: note title equals: 'This is just a new note'.
	self assert: note creationDate equals: '2025-01-01' asDateAndTime.
	self assert: note modificationDate equals: '2024-01-01' asDateAndTime.
	self assert: note tagsString equals: 'tag1,tag2'
]

{ #category : 'tests - loading' }
NTNoteObjectTest >> testLoadNoteWithMetadataWithMissingTags [

	| noteFile metadata |
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	metadata := self
		            generateMetaDataWithCreationDate:
		            '2025-01-01' asDateAndTime
		            modificationDate: '2024-01-01' asDateAndTime.
	noteFile writeStreamDo: [ :stream |
			stream
				nextPutAll: metadata;
				nextPutAll: String crlf;
				nextPutAll: String crlf;
				nextPutAll: 'This is just a new note' ].

	note := NTNote newFromFileReference: noteFile.

	self assert: note exists.
	self assert: note contents equals: 'This is just a new note'.
	self assert: note fileName equals: '2024-06-12_newNote.md'.
	self assert: note title equals: 'This is just a new note'.
	self assert: note creationDate equals: '2025-01-01' asDateAndTime.
	self assert: note modificationDate equals: '2024-01-01' asDateAndTime
]

{ #category : 'tests - loading' }
NTNoteObjectTest >> testLoadNoteWithoutMetadata [

	| noteFile |
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	noteFile writeStreamDo: [ :stream |
		stream nextPutAll: 'This is just a new note' ].

	note := NTNote newFromFileReference: noteFile.

	self assert: note exists.
	self assert: note contents equals: 'This is just a new note'.
	self assert: note fileName equals: '2024-06-12_newNote.md'.
	self assert: note title equals: 'This is just a new note'
]

{ #category : 'tests' }
NTNoteObjectTest >> testNoteCreationAndModificationDates [
	"Test that creation and modification dates are correctly set for notes"

	| creationDate modificationDate |
	
	creationDate := note creationDate.
	modificationDate := note modificationDate.

	self assert: creationDate notNil.
	self assert: modificationDate notNil.
	self assert: creationDate equals: modificationDate
]

{ #category : 'tests' }
NTNoteObjectTest >> testNoteModificationDoesNotUpdateCreationDate [
	"Test that modifying a note does not update the creation date"

	| creationDate initialModificationDate updatedCreationDate |
	creationDate := note creationDate.
	initialModificationDate := note modificationDate.

	"Simulate some modification after a delay"
	(Delay forSeconds: 0.1) wait.
	note contents: 'testMock Modified content'.

	updatedCreationDate := note creationDate.

	self assert: updatedCreationDate equals: creationDate
]

{ #category : 'tests' }
NTNoteObjectTest >> testNoteModificationUpdatesModificationDate [
	"Test that modifying a note updates the modification date"

	| creationDate initialModificationDate updatedModificationDate |
	
	creationDate := note creationDate.
	initialModificationDate := note modificationDate.

	"Simulate some modification after a delay"
	(Delay forSeconds: 0.1) wait.
	note contents: 'testMock Modified content'.

	updatedModificationDate := note modificationDate.

	self assert: updatedModificationDate > initialModificationDate
]

{ #category : 'tests - saving' }
NTNoteObjectTest >> testSaveExistingFileWithDifferentTitle [

	| modificationDate metadata finalContents fileName |
	note contents: 'Ceci est un test'.
	modificationDate := note modificationDate.
	note folderReference: memoryFS.
	note save.
	fileName := note fileName.
	note contents: 'I change the title'.
	note save.

	self denyEmpty: note fileReference contents.

	metadata := self
		            generateMetaDataWithCreationDate: note creationDate
		            modificationDate: note modificationDate.
	finalContents := metadata , String crlf , String crlf
	                 , 'I change the title'.

	self assert: note fileReference contents equals: finalContents.
	self assert: note fileName equals: fileName
]

{ #category : 'tests - saving' }
NTNoteObjectTest >> testSaveNote [

	| modificationDate metadata finalContents |
	note contents: 'Ceci est un test'.
	modificationDate := note modificationDate.
	note folderReference: memoryFS.
	note save.

	self denyEmpty: note fileReference contents.

	metadata := self
		            generateMetaDataWithCreationDate: note creationDate
		            modificationDate: note modificationDate.
	finalContents := metadata , String crlf , String crlf
	                 , 'Ceci est un test'.

	self assert: note fileReference contents equals: finalContents
]

{ #category : 'tests - saving' }
NTNoteObjectTest >> testSaveNoteLoadedWithoutMetadata [

	| modificationDate metadata finalContents noteFile |
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	noteFile writeStreamDo: [ :stream |
		stream nextPutAll: 'This is just a new note' ].

	note := NTNote newFromFileReference: noteFile.

	modificationDate := note modificationDate.
	note folderReference: memoryFS.
	note save.

	self denyEmpty: note fileReference contents.

	metadata := self
		            generateMetaDataWithCreationDate: note creationDate
		            modificationDate: note modificationDate.
	finalContents := metadata , String crlf , String crlf
	                 , 'This is just a new note'.

	self assert: note fileReference contents equals: finalContents
]

{ #category : 'tests - saving' }
NTNoteObjectTest >> testSaveNoteWithLessContents [

	| modificationDate metadata finalContents |
	note contents: 'Ceci est un test'.
	modificationDate := note modificationDate.
	note folderReference: memoryFS.
	note save.

	note contents: 'Ceci'.
	note save.

	self denyEmpty: note fileReference contents.

	metadata := self
		            generateMetaDataWithCreationDate: note creationDate
		            modificationDate: note modificationDate.
	finalContents := metadata , String crlf , String crlf , 'Ceci'.

	self assert: note fileReference contents equals: finalContents
]
