Class {
	#name : 'NTSpNoteTakerMainUITest',
	#superclass : 'NTSpApplicationTest',
	#instVars : [
		'presenter',
		'editorPresenter',
		'indexPresenter',
		'toolbarPresenter'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpNoteTakerMainUITest >> generateNoteAndTags [

	| note1 note2 note3 tag1 tag2 tag3 |
	note1 := noteContainer addNoteNamed: 'note1'.
	note2 := noteContainer addNoteNamed: 'note2'.
	note3 := noteContainer addNoteNamed: 'note3'.
	
	tag1 := noteContainer addTagNamed: 'tag1'.
	tag2 := noteContainer addTagNamed: 'tag2'.
	tag3 := noteContainer addTagNamed: 'tag3'.
	
	note1 addTag: tag1.
	note1 addTag: tag3.
	note2 addTag: tag2.
]

{ #category : 'accessing' }
NTSpNoteTakerMainUITest >> getNote1 [

	^ noteContainer noteTitled: 'note1'
]

{ #category : 'accessing' }
NTSpNoteTakerMainUITest >> getNote2 [

	^ noteContainer noteTitled: 'note2'
]

{ #category : 'accessing' }
NTSpNoteTakerMainUITest >> getNote3 [

	^ noteContainer noteTitled: 'note3'
]

{ #category : 'accessing' }
NTSpNoteTakerMainUITest >> getTag1 [

	^ noteContainer tagNamed: 'tag1'
]

{ #category : 'accessing' }
NTSpNoteTakerMainUITest >> getTag2 [

	^ noteContainer tagNamed: 'tag2'
]

{ #category : 'accessing' }
NTSpNoteTakerMainUITest >> getTag3 [

	^ noteContainer tagNamed: 'tag3'
]

{ #category : 'running' }
NTSpNoteTakerMainUITest >> setUp [

	super setUp.

	app start.
	presenter := app noteTakerMain.
	indexPresenter := presenter notesIndexPresenter.
	editorPresenter := presenter notesEditorPresenter.
	toolbarPresenter := presenter notesToolbarPresenter.

	self generateNoteAndTags.
	indexPresenter updatePresenter
]

{ #category : 'running' }
NTSpNoteTakerMainUITest >> tearDown [

	presenter application closeAllWindows.
	presenter delete
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddContent [

	| tempNote note |
	note := self getNote1.
	editorPresenter setModel: note.

	editorPresenter textInputText: 'It''s just a test'.

	tempNote := editorPresenter model.
	tempNote folderReference: memoryFS workingDirectory.
	editorPresenter saveFile.

	self assert: note contents equals: 'It''s just a test'
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsContents [

	| tempNote |
	editorPresenter newEmptyNote.
	editorPresenter textInputText: 'just a new note'.

	tempNote := editorPresenter model.
	tempNote folderReference: memoryFS workingDirectory.

	editorPresenter saveFile.

	self assert: editorPresenter model exists.
	self assert:
		(editorPresenter model fileReference basename includesSubstring:
			 'justanew')
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddNoteByItsName [

	| sizeNotesBeforeAddNote |
	sizeNotesBeforeAddNote := indexPresenter items size.
	noteContainer addNoteNamed: 'note1'.
	indexPresenter updatePresenter.
	self
		assert: indexPresenter items size
		equals: sizeNotesBeforeAddNote + 1
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddTagSaveNote [

	| tag newNote note |
	note := self getNote3.
	note folderReference: memoryFS workingDirectory.
	tag := self getTag1.
	indexPresenter selectNote: note.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag1 ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpAddTagCommand new
					context: indexPresenter;
					execute ].
	newNote := NTNoteObject newFromFileReference: note fileReference.
	self assert: newNote tagsString equals: tag tagName
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddTagToMultipleNotes [

	| tag note3 note2 |
	note2 := self getNote2.
	note3 := self getNote3.
	tag := self getTag1.
	indexPresenter selectNote: note3.
	indexPresenter selectNote: note2.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag1 ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpAddTagCommand new
					context: indexPresenter;
					execute ].

	self assert: tag notes size equals: 2.
	self assert: (note3 tags includes: tag).
	self assert: (note2 tags includes: tag)
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testAddTagToSingleNote [

	| tag note |
	note := self getNote3.
	tag := self getTag1.
	indexPresenter selectNote: note.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag1 ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpAddTagCommand new
					context: indexPresenter;
					execute ].

	self assert: note tags size equals: 1.
	self assert: (note tags includes: tag)
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testCreateANoteSelectIt [

	self skip.
	toolbarPresenter searchBarPresenter type: 'createNote'.
	toolbarPresenter searchBarPresenter typeByChar: String cr.

	self
		assert: indexPresenter selectedNote
		equals: (noteContainer noteNamed: 'createNote')
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testFilterNotesWithToolbarSetIndexItems [

	self assert: indexPresenter items size equals: 3.

	toolbarPresenter searchBarPresenter type: 'note1'.
	self assert: indexPresenter items size equals: 1
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testIndexSelectNoteSendItToEditor [

	| note |
	note := self getNote1.
	indexPresenter selectNote: note.

	self assert: editorPresenter model equals: note
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testNameNoteIsInISOFormat [

	| date tempNote note |
	note := self getNote1.
	editorPresenter setModel: note.

	date := DateAndTime now asDate yyyymmdd.

	tempNote := editorPresenter model.
	tempNote folderReference: memoryFS workingDirectory.

	editorPresenter saveFile.

	self assert: (note fileName beginsWith: date)
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testRemoveTagSaveNote [

	| tag newNote note |
	note := self getNote2.
	note folderReference: memoryFS workingDirectory.
	tag := self getTag2.
	indexPresenter selectNote: note.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag2 ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpRemoveTagCommand new
					context: indexPresenter;
					execute ].
	newNote := NTNoteObject newFromFileReference: note fileReference.
	self assert: newNote tagsString isNil
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testRemoveTagToMultipleNotes [

	| tag note3 note2 |
	note3 := self getNote3.
	note2 := self getNote2.
	tag := self getTag2.
	note3 addTag: tag.
	indexPresenter selectNote: note3.
	indexPresenter selectNote: note2.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpRemoveTagCommand new
					context: indexPresenter;
					execute ].

	self assert: tag notes size equals: 0
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testRemoveTagToSingleNote [

	| tag note |
	note := self getNote2.
	tag := self getTag2.
	indexPresenter selectNote: note.

	SpWindowSimulateOpenModal
		value: [ :aDialogPresenter |
				aDialogPresenter presenter selectedItems: #( tag2 ).
				aDialogPresenter presenter accept ]
		during: [
				NTSpRemoveTagCommand new
					context: indexPresenter;
					execute ].

	self assert: note tags size equals: 0
]

{ #category : 'tests' }
NTSpNoteTakerMainUITest >> testSelectANote [

	indexPresenter selectNote: self getNote1.

	self
		assert: editorPresenter textInputText
		equals: self getNote1 contents
]
