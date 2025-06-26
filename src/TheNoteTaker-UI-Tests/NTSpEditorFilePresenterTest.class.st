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
NTSpEditorFilePresenterTest >> testSaveWithExtension [

	| text textPresenter |self skip.
	text := 'This is just a test'.
	textPresenter := self mockTextObject: text.
	presenter textInputText: text.
	presenter note: note.
	note title: 'Dummy title'.
	presenter saveFile.

	self assert: note title suffix equals: 'md'.
	self assert: note contents equals: text
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testTextInputTextIsSpecify [
	
	presenter textInputText: 'test'.
	self assert: presenter textInputText equals: 'test'
]
