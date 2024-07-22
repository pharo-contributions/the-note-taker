Class {
	#name : 'NTMDEditorPresenter',
	#superclass : 'MDEditorPresenter',
	#instVars : [
		'actualNote'
	],
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'accessing' }
NTMDEditorPresenter >> actualNote [

^actualNote
]

{ #category : 'accessing' }
NTMDEditorPresenter >> actualNote: aNoteObject [

actualNote := aNoteObject 
]

{ #category : 'display' }
NTMDEditorPresenter >> displayContents: aNoteObject [
self cleanInput.
actualNote := aNoteObject.
textInput text: aNoteObject contents asString.
self renderDocument.
]

{ #category : 'initialization' }
NTMDEditorPresenter >> initializePresentersWithText: anInputText [

	super initializePresentersWithText: anInputText.
	textInput whenTextChangedDo: [ self 
		renderDocument.
		actualNote ifNotNil:[
			actualNote contents: textInput text asString]]
]

{ #category : 'actions' }
NTMDEditorPresenter >> openNote: aNoteObject [

	self mdFile: (MDFile newFromFileReference: aNoteObject title asFileReference).
	textInput text: aNoteObject contents.
	self cleanOutput.
	self window ifNotNil: [self updateTitle].
	self renderDocument.
]

{ #category : 'actions' }
NTMDEditorPresenter >> save: aText withExtension: anExtension [

	self shouldBeImplemented 
]

{ #category : 'api' }
NTMDEditorPresenter >> title [

	^ 'NoteTaker - ' , self owner selectedNoteTitle
]
