Class {
	#name : 'NTSpEditorFilePresenterTest',
	#superclass : 'NTSpTestCase',
	#instVars : [
		'note',
		'fileReference',
		'editorPresenter'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpEditorFilePresenterTest >> setUp [

	| text |
	super setUp.

	text := 'This is just a test'.
	fileReference := memoryFS / 'aFileReference.md'.
	fileReference writeStreamDo: [ :stream | stream nextPutAll: text ].

	editorPresenter := NTSpEditorPresenter newApplication: app.

	note := NTNote newFromFileReference: fileReference
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> tearDown [

	fileReference ensureDelete.
	editorPresenter ifNotNil: [editorPresenter delete].
	super tearDown
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testCleanAction [

	editorPresenter emptyInputText.
	self assert: editorPresenter textInputText equals: ''.
	self assert: editorPresenter renderedText equals: ''
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> testCreateNewNoteBySettingModelDontSaveIt [

	| newNote |
	editorPresenter setModel: nil.
	newNote := editorPresenter model.
	
	self deny: newNote exists.
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testCreateNewNoteDontSaveIt [

	| newNote |
	editorPresenter newEmptyNote.
	newNote := editorPresenter model.
	
	self deny: newNote exists.
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testCreateNewNoteDontSaveItWhenAutoSave [

	| newNote initialAutoSave |
	initialAutoSave := editorPresenter class AutoSave.
	editorPresenter class AutoSave: true.
	editorPresenter newEmptyNote.
	newNote := editorPresenter model.
	
	editorPresenter class AutoSave: initialAutoSave.

	self deny: newNote exists
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testGotCurrentFileWhenIsNotSpecify [

	self assert: editorPresenter model class equals: NTNote
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testGotCurrentFileWhenIsSpecify [

	editorPresenter setModel: note.
	self assert: editorPresenter model class equals: NTNote
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> testRenderedTextIsCorrectMicrodown [

	| text composer micText |
	composer := MicRichTextComposer new.
	text := 'This **is** just a __test__'.
	micText := composer visit: (Microdown parse: text).

	editorPresenter setModel: note.
	editorPresenter textInputText: text.
	editorPresenter renderDocument.

	self assert: editorPresenter renderedText equals: micText
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> testSave [

	| text |
	
	text := 'This is just a test'.

	editorPresenter setModel: note.
	editorPresenter textInputText: text.
	editorPresenter saveFile.

	self assert: note contents equals: text.
	self assert: note exists.
	"We use endsWith: due to metadata"
	self assert: (note fileReference contents endsWith: text)
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> testSaveWhenNoteDirty [

	| text noteFile modifTime |
	text := 'This is just a new note'.
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	noteFile writeStreamDo: [ :stream | stream nextPutAll: text ].
	modifTime := noteFile modificationTime.

	note := NTNote newFromFileReference: noteFile.
	(Delay forSeconds: 0.01) wait.
	editorPresenter setModel: note.

	note contents: 'test'.
	editorPresenter saveFile.

	self deny: noteFile modificationTime equals: modifTime
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> testSaveWhenNoteNotDirty [

	| text noteFile modifTime |
	text := 'This is just a new note'.
	noteFile := memoryFS / '2024-06-12_newNote.md'.
	noteFile writeStreamDo: [ :stream | stream nextPutAll: text ].
	modifTime := noteFile modificationTime.

	note := NTNote newFromFileReference: noteFile.

	editorPresenter setModel: note.
	editorPresenter saveFile.

	self assert: noteFile modificationTime equals: modifTime
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testTextInputTextIsSpecify [

	editorPresenter textInputText: 'test'.
	self assert: editorPresenter textInputText equals: 'test'
]
