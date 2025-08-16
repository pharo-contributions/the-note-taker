Class {
	#name : 'NTContainerTest',
	#superclass : 'TestCase',
	#instVars : [
		'noteTakerContainer',
		'ressources',
		'memoryFS'
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
	memoryFS := FileSystem memory workingDirectory.

	ressources := NTTestResource new
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

{ #category : 'tests - tags' }
NTContainerTest >> testImportEmptyFolder [

	| folderReference |
	self assertEmpty: noteTakerContainer notes.

	folderReference := memoryFS / 'folder' / 'note'.
	folderReference ensureCreateDirectory.

	noteTakerContainer importFolder: folderReference.

	self assert: noteTakerContainer notesCount equals: 0
]

{ #category : 'tests - tags' }
NTContainerTest >> testImportFolder [

	| folderReference fileReference1 fileReference2 fileReference3 |
	self assertEmpty: noteTakerContainer notes.

	folderReference := memoryFS / 'folder' / 'note'.
	folderReference ensureCreateDirectory.

	fileReference1 := folderReference / 'aFileReference1.md'.
	fileReference1 ensureCreateFile.

	fileReference2 := folderReference / 'aFileReference2.md'.
	fileReference2 ensureCreateFile.

	fileReference3 := folderReference / 'aFileReference3.md'.
	fileReference3 ensureCreateFile.
	
	noteTakerContainer importFolder: folderReference.

	self assert: noteTakerContainer notesCount equals: 3.
]

{ #category : 'tests - tags' }
NTContainerTest >> testImportFolderWithFileWithoutAvailableExtensions [

	| folderReference fileReference1 fileReference2 fileReference3 |
	self assertEmpty: noteTakerContainer notes.

	folderReference := memoryFS / 'folder' / 'note'.
	folderReference ensureCreateDirectory.

	fileReference1 := folderReference / 'aFileReference1.png'.
	fileReference1 ensureCreateFile.

	fileReference2 := folderReference / 'aFileReference2.html'.
	fileReference2 ensureCreateFile.

	fileReference3 := folderReference / 'aFileReference3.css'.
	fileReference3 ensureCreateFile.

	noteTakerContainer importFolder: folderReference.

	self assert: noteTakerContainer notesCount equals: 0
]

{ #category : 'tests - note' }
NTContainerTest >> testLoadNoteWithAllMetadata [

	| noteFile metadata tags note |
	ressources addingNotesAndTagsTo: noteTakerContainer.
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	tags := OrderedCollection new
		        add: ressources getTag1;
		        add: ressources getTag2;
		        yourself.
	metadata := NTNoteTest new
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

	note := noteTakerContainer addNoteFromFileReference: noteFile.

	self assert: note exists.
	self assert: note contents equals: 'This is just a new note'.
	self assert: note fileName equals: '2024-06-12_newNote.md'.
	self assert: note title equals: 'This is just a new note'.
	self assert: note creationDate equals: '2025-01-01' asDateAndTime.
	self assert: note modificationDate equals: '2024-01-01' asDateAndTime.
	self assert: (note tags includesAll: tags)
]

{ #category : 'tests - note' }
NTContainerTest >> testLoadNoteWithMetadataWithMissingTags [

	| noteFile metadata note |
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	metadata := NTNoteTest new
		            generateMetaDataWithCreationDate:
		            '2025-01-01' asDateAndTime
		            modificationDate: '2024-01-01' asDateAndTime.
	noteFile writeStreamDo: [ :stream |
			stream
				nextPutAll: metadata;
				nextPutAll: String crlf;
				nextPutAll: String crlf;
				nextPutAll: 'This is just a new note' ].

	note := noteTakerContainer addNoteFromFileReference: noteFile.

	self assert: note exists.
	self assert: note contents equals: 'This is just a new note'.
	self assert: note fileName equals: '2024-06-12_newNote.md'.
	self assert: note title equals: 'This is just a new note'.
	self assert: note creationDate equals: '2025-01-01' asDateAndTime.
	self assert: note modificationDate equals: '2024-01-01' asDateAndTime
]

{ #category : 'tests - note' }
NTContainerTest >> testLoadNoteWithoutMetadata [

	| noteFile note |
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	noteFile writeStreamDo: [ :stream |
		stream nextPutAll: 'This is just a new note' ].

	note := noteTakerContainer addNoteFromFileReference: noteFile.

	self assert: note exists.
	self assert: note contents equals: 'This is just a new note'.
	self assert: note fileName equals: '2024-06-12_newNote.md'.
	self assert: note title equals: 'This is just a new note'.
	self assert: note creationDate equals: noteFile creationTime asDateAndTime.
	self assert: note modificationDate equals: noteFile modificationTime asDateAndTime
]

{ #category : 'tests - scenarios' }
NTContainerTest >> testNotesContentMatching [

	| note |
	ressources addingNotesAndTagsTo: noteTakerContainer.
	note := NTNote content: 'TITLE', String crlf, 'note content'.
	noteTakerContainer addNote: note.

	self
		assert: (noteTakerContainer notesContentsMatching: '') size
		equals: 4.

	self
		assert: (noteTakerContainer notesContentsMatching: 'note') size
		equals: 4.

	self
		assert: (noteTakerContainer notesContentsMatching: 'TITLE') size
		equals: 1.
		
	self
		assert: (noteTakerContainer notesContentsMatching: 'content') size
		equals: 1
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

{ #category : 'tests - note' }
NTContainerTest >> testSaveNoteLoadedWithoutMetadata [

	| modificationDate metadata finalContents noteFile note |
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	noteFile writeStreamDo: [ :stream |
		stream nextPutAll: 'This is just a new note' ].

	note := noteTakerContainer addNoteFromFileReference: noteFile.

	modificationDate := note modificationDate.
	note folderReference: memoryFS.
	note save.

	self denyEmpty: note fileReference contents.

	metadata := NTNoteTest new
		            generateMetaDataWithCreationDate: note creationDate
		            modificationDate: note modificationDate.
	finalContents := metadata , String crlf , String crlf
	                 , 'This is just a new note'.

	self assert: note fileReference contents equals: finalContents
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
