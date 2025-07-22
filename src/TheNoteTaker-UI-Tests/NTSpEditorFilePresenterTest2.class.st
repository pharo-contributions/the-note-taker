Class {
	#name : 'NTSpEditorFilePresenterTest2',
	#superclass : 'NTSpApplicationTest',
	#instVars : [
		'note',
		'fileReference',
		'editorPresenter'
	],
	#category : 'TheNoteTaker-UI-Tests',
	#package : 'TheNoteTaker-UI-Tests'
}

{ #category : 'running' }
NTSpEditorFilePresenterTest2 >> mockTextObject: aString [ 

	^ SpTextPresenter new text: aString 
]

{ #category : 'running' }
NTSpEditorFilePresenterTest2 >> setUp [

	| text |
	super setUp.

	text := 'This is just a test'.
	memoryFS := FileSystem memory.
	fileReference := memoryFS / 'aFileReference.md'.
	fileReference writeStreamDo: [ :stream | stream nextPutAll: text ].

	app := NTSpApplication new.
	editorPresenter := NTSpEditorPresenter newApplication: app.

	note := NTNoteObject newFromFileReference: fileReference
]

{ #category : 'running' }
NTSpEditorFilePresenterTest2 >> tearDown [

	fileReference ensureDelete.
	super tearDown
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest2 >> testCleanAction [

	editorPresenter emptyInputText.
	self assert: editorPresenter textInputText equals: ''.
	self assert: editorPresenter renderedText equals: ''
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest2 >> testGotCurrentFileWhenIsNotSpecify [

	self assert: editorPresenter model class equals: NTNoteObject
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest2 >> testGotCurrentFileWhenIsSpecify [

	editorPresenter setModel: note.
	self assert: editorPresenter model class equals: NTNoteObject
]

{ #category : 'running' }
NTSpEditorFilePresenterTest2 >> testRenderedTextIsCorrectMicrodown [

	| text composer micText |
	composer := MicRichTextComposer new.
	text := 'This **is** just a __test__'.
	micText := composer visit: (Microdown parse: text).

	editorPresenter setModel: note.
	editorPresenter textInputText: text.

	self assert: editorPresenter renderedText equals: micText
]

{ #category : 'running' }
NTSpEditorFilePresenterTest2 >> testSave [

	| text |self skip.
	text := 'This is just a test'.

	editorPresenter setModel: note.
	editorPresenter textInputText: text.
	editorPresenter saveFile.

	self assert: note contents equals: text.
	self assert: note exists.
	"We use endsWith: due to metadata"
	self assert: (note fileReference contents endsWith: text)
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest2 >> testTextInputTextIsSpecify [

	editorPresenter textInputText: 'test'.
	self assert: editorPresenter textInputText equals: 'test'
]
