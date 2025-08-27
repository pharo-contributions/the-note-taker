Class {
	#name : 'NTSpApplicationTest',
	#superclass : 'NTSpTestCase',
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'tests' }
NTSpApplicationTest >> testChangeCurrentFolderImportIt [

	| noteFile |
	(memoryFS / 'test') ensureCreateDirectory.
	noteFile := memoryFS / 'test' / '2024-06-12_newNote.md'.
	noteFile writeStreamDo: [ :stream |
		stream nextPutAll: 'This is just a new note' ].
	
	self assertEmpty: noteContainer notes.
	
	app currentFolder: (memoryFS / 'test').
	
	self assert: noteContainer notesCount equals: 1.
	self assert: (noteContainer notesContentsMatching: 'This is just a new note') size equals: 1
]
