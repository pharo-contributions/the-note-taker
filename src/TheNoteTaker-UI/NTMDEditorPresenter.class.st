Class {
	#name : 'NTMDEditorPresenter',
	#superclass : 'MDEditorPresenter',
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'private' }
NTMDEditorPresenter >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'initialization' }
NTMDEditorPresenter >> initializePresentersWithText: anInputText [

	super initializePresentersWithText: anInputText.
	textInput whenTextChangedDo: [ self renderDocument ]
]

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

	| nameOfNote nameWithExtension |
	nameOfNote := (aText asString substrings: String cr) first trimBoth.
	nameWithExtension := nameOfNote , '.' , anExtension.

	nameWithExtension asFileReference writeStreamDo: [ :stream |
		stream nextPutAll: aText ]
]

{ #category : 'api' }
NTMDEditorPresenter >> title [

	^ String streamContents: [ : stream |
		stream 
			<< self applicationTitle;
			<< self owner selectedNoteTitle ]
]
