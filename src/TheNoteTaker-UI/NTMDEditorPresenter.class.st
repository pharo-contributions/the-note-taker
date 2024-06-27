Class {
	#name : 'NTMDEditorPresenter',
	#superclass : 'MDEditorPresenter',
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'actions' }
NTMDEditorPresenter >> openNote: aNoteObject [

	self currentFileState: MDEditorOpenedFile new.
	textInput text: aNoteObject contents.
	self cleanOutput.
	self updateTitle.
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
