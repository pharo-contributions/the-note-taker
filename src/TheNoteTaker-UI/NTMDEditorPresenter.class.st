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

{ #category : 'visiting' }
NTMDEditorPresenter >> accept [

	currentFile file writeStreamDo: [ :str |
		str nextPutAll: self text asString ].
	self inform: 'Note ' , currentFile file fullName , ' saved'
]

{ #category : 'accessing' }
NTMDEditorPresenter >> actualNote [

^actualNote
]

{ #category : 'accessing' }
NTMDEditorPresenter >> actualNote: aNoteObject [

actualNote := aNoteObject 
]

{ #category : 'private' }
NTMDEditorPresenter >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'display' }
NTMDEditorPresenter >> displayContents: aNoteObject [
self cleanInput.
actualNote := aNoteObject.
textInput text: aNoteObject contents asString.
self renderDocument.
]

{ #category : 'initialization' }
NTMDEditorPresenter >> initialize [ 

	super initialize.
	self noNote
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

	self mdFile: (MDFile newFromFileReference: aNoteObject title asFileReference).
	textInput text: aNoteObject contents.
	self cleanOutput.
	self window ifNotNil: [self updateTitle].
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
