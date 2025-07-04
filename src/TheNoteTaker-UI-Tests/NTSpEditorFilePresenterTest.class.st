Class {
	#name : 'NTSpEditorFilePresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'memoryFS',
		'presenter',
		'note',
		'fileReference'
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
	memoryFS := FileSystem memory.
	presenter := NTSpEditorPresenter new.
	
	text := 'This is just a test'.
	fileReference := memoryFS / 'aFileReference.md'.
	fileReference writeStreamDo: [ :stream | stream nextPutAll: text ].

	note := NTNoteObject newFromFileReference: fileReference
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> tearDown [

	fileReference ensureDelete.
	super tearDown
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testCleanAction [

	presenter emptyInputText.
	self assert: presenter textInputText equals: ''.
	self assert: presenter renderedText equals: ''
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testGotCurrentFileWhenIsNotSpecify [

	self assert: presenter note class equals: NTNoteObject 
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testGotCurrentFileWhenIsSpecify [

	presenter note: note.
	self assert: presenter note class equals: NTNoteObject
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> testRenderedTextIsCorrectMicrodown [

	| text composer micText |
	composer := MicRichTextComposer new.
	text := 'This **is** just a __test__'.
	micText := composer visit: (Microdown parse: text).

	presenter note: note.
	presenter textInputText: text.

	self assert: presenter renderedText equals: micText
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> testSave [

	| text |
	text := 'This is just a test'.

	presenter note: note.
	presenter textInputText: text.
	presenter saveFile.

	self assert: note contents equals: text.
	self assert: note exists.
	"We use endsWith: due to metadata"
	self assert: (note fileReference contents endsWith: text)
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testTextInputTextIsSpecify [
	
	presenter textInputText: 'test'.
	self assert: presenter textInputText equals: 'test'
]
