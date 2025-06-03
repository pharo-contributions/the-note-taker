Class {
	#name : 'NTMDEditorPresenter',
	#superclass : 'NTEditorPresenter',
	#category : 'TheNoteTaker-UI-Core',
	#package : 'TheNoteTaker-UI',
	#tag : 'Core'
}

{ #category : 'visiting' }
NTMDEditorPresenter >> accept [

	note fileReference writeStreamDo: [ :str |
		str nextPutAll: self text asString ].
	self inform: 'Note ' , note fileReference fullName , ' saved'
]

{ #category : 'private' }
NTMDEditorPresenter >> applicationTitle [

	^ self application applicationTitle
]

{ #category : 'display' }
NTMDEditorPresenter >> displayContents: aNoteObject [

	note := aNoteObject.
	textInput text: aNoteObject contents asString.
	self renderDocument
]

{ #category : 'initialization' }
NTMDEditorPresenter >> initialize [ 

	super initialize.
	self noNote
]

{ #category : 'api' }
NTMDEditorPresenter >> initializeMenuBar [

	super initializeMenuBar.

	menu
		addGroup: [ :group | 
			group addItem: [ :item | 
				item
					name: 'Toggle Preview';
					description: 'Show/Hide the preview pane';
					icon: (self iconNamed: #smallInspectIt);
					action: [ self togglePreview ] ] ]
]

{ #category : 'initialization' }
NTMDEditorPresenter >> initializePresentersWithText: anInputText [

	super initializePresentersWithText: anInputText.
	textInput
		whenTextChangedDo: [
			self renderDocument.
			note ifNotNil: [
					note contents: textInput text asString ] ];
		bindKeyCombination: $s meta toAction: [ self accept ]
]

{ #category : 'actions' }
NTMDEditorPresenter >> newNote: aNoteObject [

	"self mdFile: (MDFile new title: aNoteObject title)."
	self window ifNotNil: [ self updateTitle ].
	self note addMetaDataElements. 
	textInput text: self note contents.
	self emptyRenderedText.
	self renderDocument.
	note := aNoteObject.
	note title: self note fileReference basename.
	note contents: textInput text
]

{ #category : 'initialization' }
NTMDEditorPresenter >> noNote [

	note := NTNoteObject new
]

{ #category : 'actions' }
NTMDEditorPresenter >> openNote: aNoteObject [

	textInput text: aNoteObject contents.
	self emptyRenderedText.
	self window ifNotNil: [self updateTitle].
	self renderDocument.
	note := aNoteObject.
	note contents: self textInputText.
]

{ #category : 'actions' }
NTMDEditorPresenter >> saveFile [
	 
	self note hasFile ifFalse: [ self saveFileByItsContents ]. 
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
			ifTrue: [ collectionOfTextInput copyFrom: 1 to: 3 ]
			ifFalse: [ collectionOfTextInput ]) 
				do: [ :each | stt nextPutAll: each ] ].

	newNoteByItsContents := NTSingleton uniqueInstance addNoteNamed: nameOfNewNote.
	newNoteByItsContents contents: self textInputText.
	
	self emptyInputText.
	self newNote: newNoteByItsContents.
	self owner owner notesIndexPresenter refresh
]

{ #category : 'api' }
NTMDEditorPresenter >> title [
	"Answer a <String> representing the application name and selected note title"

	^ String streamContents: [ : stream |
		stream 
			<< self applicationTitle;
			<< self owner selectedNoteTitle ]
]

{ #category : 'callbacks' }
NTMDEditorPresenter >> togglePreview [

	renderedText isVisible 
		ifTrue: [ 
			| editorsLayoutPane |
			"textOutput hide."

			editorsLayoutPane := self layout children second.
			editorsLayoutPane remove: #textOutput.
			"editorsLayoutPane replaceFirst: textInput.
			self update" ]
		ifFalse: [ renderedText show ]
]
