Class {
	#name : 'NTSpEditorFilePresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'window',
		'memoryFS',
		'presenter',
		'mdFile',
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
	presenter := MDEditorPresenter new.
	
	text := 'This is just a test'.
	fileReference := memoryFS / 'aFileReference.md'.
	fileReference writeStreamDo: [ :stream | stream nextPutAll: text ].

	mdFile := MDFile newFromFileReference: fileReference
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

	self assert: presenter mdFile class equals: MDFile
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testGotCurrentFileWhenIsSpecify [

	presenter mdFile: mdFile.
	self assert: presenter mdFile class equals: MDFile
]

{ #category : 'running' }
NTSpEditorFilePresenterTest >> testSaveWithExtension [

	| text textPresenter |
	text := 'This is just a test'.
	textPresenter := self mockTextObject: text.
	presenter textInputText: text.
	presenter mdFile: mdFile.
	mdFile title: 'Dummy title'.
	presenter saveFile.

	self assert: mdFile extension equals: 'md'.
	self assert: mdFile contents equals: text
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testTextInputTextIsNotSpecify [
	
	self assert: presenter textInputText equals: '% Type your marked-up text here. Render it and see right the output generated as rich text', String cr, String cr, presenter exampleText
]

{ #category : 'tests' }
NTSpEditorFilePresenterTest >> testTextInputTextIsSpecify [
	
	presenter textInputText: 'test'.
	self assert: presenter textInputText equals: 'test'
]
