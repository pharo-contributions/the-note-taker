Class {
	#name : 'NTSpNoteTakerMainUITest',
	#superclass : 'NTSpApplicationTest',
	#instVars : [
		'presenter',
		'notesToolbarPresenter',
		'notesIndexPresenter',
		'notesContentPresenter',
		'note',
		'noteFile'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpNoteTakerMainUITest >> notesIndexPresenter [

	^ presenter notesIndexPresenter
]

{ #category : 'running' }
NTSpNoteTakerMainUITest >> notesToolbarPresenter [
	^ presenter notesToolbarPresenter
]

{ #category : 'running' }
NTSpNoteTakerMainUITest >> setUp [

	| noteFileName |
	super setUp.

	app start.
	presenter := app noteTakerMain.
	notesIndexPresenter := presenter notesIndexPresenter.
	notesContentPresenter := presenter notesEditorPresenter.
	notesToolbarPresenter := presenter notesToolbarPresenter.

	noteFile := memoryFS workingDirectory / 'newNote.md'.
	noteFile writeStreamDo: [ :stream | "noteFileName := (noteContainer addNoteFromFileReference: noteFile)
		                fileName.
	note := noteContainer noteNamed: noteFileName.
	notesContentPresenter note: note"
		stream nextPutAll: 'new note' ]
]

{ #category : 'running' }
NTSpNoteTakerMainUITest >> tearDown [

	presenter application closeAllWindows.
	presenter delete
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddContent [

	| tempNote noteFileName |
	
	noteFileName := (noteContainer addNoteFromFileReference: noteFile)
		                fileName.
	note := noteContainer noteNamed: noteFileName.
	notesContentPresenter note: note.
	
	notesContentPresenter textInputText: 'It''s just a test'.

	tempNote := notesContentPresenter note.
	tempNote folderReference: memoryFS workingDirectory.
	notesContentPresenter saveFile.

	self assert: note contents equals: 'It''s just a test'
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsContents [

	| tempNote |
   notesContentPresenter noNote.
	notesContentPresenter textInputText: 'just a new note'.

	tempNote := notesContentPresenter note.
	tempNote folderReference: memoryFS workingDirectory.

	notesContentPresenter saveFile.

	self assert: notesContentPresenter note exists.
	self assert:
		(notesContentPresenter note fileReference basename
			 includesSubstring: 'justanew')
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsName [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := notesIndexPresenter items size.
	noteContainer addNoteNamed: 'note1'.
	self
		assert: notesIndexPresenter items size
		equals: sizeNotesBeforeAddNote + 1
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddTagSaveNote [

	| tag newNote |
	note := noteContainer addNoteNamed: 'Test'.
	note folderReference: memoryFS workingDirectory.
	tag := noteContainer addTagNamed: 'tag'.
	notesIndexPresenter selectNote: note.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpAddTagCommand new
					context: notesIndexPresenter;
					execute ].
	newNote := NTNoteObject newFromFileReference: note fileReference.
	self assert: newNote tagsString equals: 'tag'
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddTagToMultipleNotes [

	| tag note1 note2 |
	note1 := noteContainer addNoteNamed: 'note1'.
	note2 := noteContainer addNoteNamed: 'note2'.
	tag := noteContainer addTagNamed: 'tag'.
	notesIndexPresenter selectNote: note1.
	notesIndexPresenter selectNote: note2.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpAddTagCommand new
					context: notesIndexPresenter;
					execute ].

	self assert: tag notes size equals: 2.
	self assert: (note1 tags includes: tag).
	self assert: (note2 tags includes: tag)
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddTagToSingleNote [

	| tag |
	note := noteContainer addNoteNamed: 'Test'.
	tag := noteContainer addTagNamed: 'tag'.
	notesIndexPresenter selectNote: note.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpAddTagCommand new
					context: notesIndexPresenter;
					execute ].

	self assert: note tags size equals: 1.
	self assert: (note tags includes: tag)
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testCreateANoteSelectIt [

	self skip.
	self notesToolbarPresenter searchBarPresenter type: 'createNote'.
	self notesToolbarPresenter searchBarPresenter typeByChar: String cr.

	self
		assert: self notesIndexPresenter selectedNote
		equals: (noteContainer noteNamed: 'createNote')
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testFilterNotesWithToolbarSetIndexItems [

	noteContainer addNoteNamed: 'note'.
	noteContainer addNoteNamed: 'Test'.
	noteContainer addNoteNamed: 'note2'.

	self assert: notesIndexPresenter items size equals: 3.
	
	notesToolbarPresenter searchBarPresenter type: 'note'.
	self assert: notesIndexPresenter items size equals: 2
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testIndexSelectNoteSendItToEditor [

	note := noteContainer addNoteNamed: 'Test'.
	notesIndexPresenter selectNote: note.
	
	self assert: notesContentPresenter note equals: note
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testNameNoteIsInISOFormat [
	" add new note in the note taker, its contents and save it"

	| date tempNote noteFileName |
	
	noteFileName := (noteContainer addNoteFromFileReference: noteFile)
		                fileName.
	note := noteContainer noteNamed: noteFileName.
	notesContentPresenter note: note.
	
	date := DateAndTime now asDate yyyymmdd.

	tempNote := notesContentPresenter note.
	tempNote folderReference: memoryFS workingDirectory.

	notesContentPresenter saveFile.

	self assert: (note fileName beginsWith: date)
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testRemoveTagSaveNote [

	| tag newNote |
	note := noteContainer addNoteNamed: 'Test'.
	note folderReference: memoryFS workingDirectory.
	tag := noteContainer addTagNamed: 'tag'.
	note addTag: tag.
	notesIndexPresenter selectNote: note.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpRemoveTagCommand new
					context: notesIndexPresenter;
					execute ].
	newNote := NTNoteObject newFromFileReference: note fileReference.
	self assert: newNote tags size equals: 0
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testRemoveTagToMultipleNotes [

	| tag note1 note2 |
	note1 := noteContainer addNoteNamed: 'note1'.
	note2 := noteContainer addNoteNamed: 'note2'.
	tag := noteContainer addTagNamed: 'tag'.
	note1 addTag: tag.
	note2 addTag: tag.
	notesIndexPresenter selectNote: note1.
	notesIndexPresenter selectNote: note2.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpRemoveTagCommand new
					context: notesIndexPresenter;
					execute ].

	self assert: tag notes size equals: 0
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testRemoveTagToSingleNote [

	| tag |
	note := noteContainer addNoteNamed: 'Test'.
	tag := noteContainer addTagNamed: 'tag'.
	note addTag: tag.
	notesIndexPresenter selectNote: note.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpRemoveTagCommand new
					context: notesIndexPresenter;
					execute ].

	self assert: note tags size equals: 0.
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testSelectANote [

	noteContainer addNoteNamed: 'anotherNote'.
	notesIndexPresenter selectNote: notesIndexPresenter items first.

	notesIndexPresenter selectedNote contents: 'anotherNote'.
	notesContentPresenter note: notesIndexPresenter selectedNote.

	self
		assert: notesContentPresenter textInputText
		equals: 'anotherNote'
]
