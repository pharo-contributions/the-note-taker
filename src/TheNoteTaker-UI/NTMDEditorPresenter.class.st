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

	mdFile file writeStreamDo: [ :str |
		str nextPutAll: self text asString ].
	self inform: 'Note ' , mdFile file fullName , ' saved'
]

{ #category : 'accessing' }
NTMDEditorPresenter >> actualNote [

	^ actualNote
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
	self renderDocument
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
		whenTextChangedDo: [
			self renderDocument.
			actualNote ifNotNil: [
					actualNote contents: textInput text asString ] ];
		bindKeyCombination: $s meta toAction: [ self accept ]
]

{ #category : 'actions' }
NTMDEditorPresenter >> newNote: aNoteObject [

	self mdFile:
		(MDFile newFromFileReference: aNoteObject title asFileReference).
	self window ifNotNil: [ self updateTitle ].
	textInput text: aNoteObject contents.
	self cleanOutput.
	self renderDocument.
	actualNote := aNoteObject.
	actualNote title: self mdFile basename.
]

{ #category : 'initialization' }
NTMDEditorPresenter >> noNote [

	mdFile := MDFile new
]

{ #category : 'actions' }
NTMDEditorPresenter >> openNote: aNoteObject [

	self mdFile: (MDFile newFromFileReference: aNoteObject title asFileReference).
	textInput text: aNoteObject contents.
	self cleanOutput.
	self window ifNotNil: [self updateTitle].
	self renderDocument.
	actualNote := aNoteObject.
	actualNote contents: self textInputText.
]

{ #category : 'actions' }
NTMDEditorPresenter >> saveFile [
	 
	self mdFile hasFile ifFalse: [ self saveFileByItsContents ]. 
	super saveFile
]

{ #category : 'actions' }
NTMDEditorPresenter >> saveFileByItsContents [
	"create a new note with its title which corresponds to the first word of the contents.
	If the contents has more than three words, the title correponds to its first three words. "

	| newNoteByItsContents nameOfNewNote collectionOfTextInput |
	
	collectionOfTextInput := self textInputText substrings.
	nameOfNewNote := String streamContents: [ :stt |
		                 (collectionOfTextInput size > 3
			                  ifTrue: [
			                  collectionOfTextInput copyFrom: 1 to: 3 ]
			                  ifFalse: [ collectionOfTextInput ]) do: [ :each |
			                 stt nextPutAll: each ] ].

	newNoteByItsContents := NTSingleton uniqueInstance addNoteNamed:
		                        nameOfNewNote.
	self owner owner notesIndexPresenter refresh.
	newNoteByItsContents contents: self textInputText.

	self newNote: newNoteByItsContents
]

{ #category : 'api' }
NTMDEditorPresenter >> title [
	"Answer a <String> representing the application name and selected note title"

	^ String streamContents: [ : stream |
		stream 
			<< self applicationTitle;
			<< self owner selectedNoteTitle ]
]
