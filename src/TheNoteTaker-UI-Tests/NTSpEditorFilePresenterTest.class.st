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
NTSpEditorFilePresenterTest >> mockTextObject: aString [ 

	^ SpTextPresenter new text: aString 
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> setUp [

	| text |
	super setUp.

	text := 'This is just a test'.
	fileReference := memoryFS / 'aFileReference.md'.
	fileReference writeStreamDo: [ :stream | stream nextPutAll: text ].

	editorPresenter := (NTSpNoteTakerMainUI newApplication: app) notesEditorPresenter.

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

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testTextInputTextIsSpecify [

	editorPresenter textInputText: 'test'.
	self assert: editorPresenter textInputText equals: 'test'
]
