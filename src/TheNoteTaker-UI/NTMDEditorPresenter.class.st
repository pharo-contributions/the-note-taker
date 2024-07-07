"
Specialized MicroEd editor for note taking application

"
Class {
	#name : 'NTMDEditorPresenter',
	#superclass : 'MDEditorPresenter',
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'visiting' }
NTMDEditorPresenter >> accept [

	currentFile file writeStreamDo: [ :str |
		str nextPutAll: self text asString ].
	self inform: 'Note ' , currentFile file fullName , ' saved'
]

{ #category : 'private' }
NTMDEditorPresenter >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'initialization' }
NTMDEditorPresenter >> initialize [ 

	super initialize.
	self noNote
]

{ #category : 'initialization' }
NTMDEditorPresenter >> initializePresentersWithText: anInputText [

	super initializePresentersWithText: anInputText.
	textInput 
		whenTextChangedDo: [ self renderDocument ];
		bindKeyCombination: $s meta toAction: [ self accept ].
]

{ #category : 'actions' }
NTMDEditorPresenter >> newNote: aNoteObject [

	self currentFileState: (MDEditorNewFile newFromNote: aNoteObject).
	self updateTitle.
	textInput text: aNoteObject contents.
	self cleanOutput.
	self renderDocument
]

{ #category : 'initialization' }
NTMDEditorPresenter >> noNote [

	currentFile := MDEditorNoFile new
]

{ #category : 'actions' }
NTMDEditorPresenter >> openNote: aNoteObject [

	self currentFileState: (MDEditorOpenedFile newFromNote: aNoteObject).
	self cleanOutput.
	textInput text: aNoteObject contents.
	self updateTitle.
	self renderDocument
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
